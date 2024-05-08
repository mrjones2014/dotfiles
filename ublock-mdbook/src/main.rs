use clap::{Arg, ArgMatches, Command};
use mdbook::{
    book::Book,
    preprocess::{CmdPreprocessor, Preprocessor, PreprocessorContext},
    BookItem,
};
use regex::Regex;
use std::io::prelude::*;
use std::{collections::HashMap, error::Error, io, process};

fn parse_ublock_filters() -> (String, String, String) {
    let filters =
        serde_yaml::from_str::<Vec<HashMap<String, String>>>(include_str!("./ublock-filters.yml"))
            .unwrap();

    let md_linkify_pattern = Regex::new(r"[^A-Za-z]").unwrap();

    let mut filters_toc = String::from("");
    let mut filters_all = String::from("");
    let mut individual_sections = String::from("");
    for item in filters.iter() {
        for (site_name, filters_text) in item.iter() {
            filters_toc.push_str(
                format!(
                    "- [{}](#{})\n",
                    site_name,
                    md_linkify_pattern
                        .replace_all(site_name.to_lowercase().as_str(), "-")
                        .replace("---", "--")
                )
                .as_str(),
            );
            individual_sections.push_str(
                format!(
                    "\n## {}\n\n```adblock\n{}\n```\n",
                    site_name,
                    filters_text.trim()
                )
                .as_str(),
            );
            filters_all.push_str(
                format!(
                    r#"
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! {}{}!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

{}

"#,
                    site_name,
                    " ".repeat(36 - site_name.len()),
                    filters_text.trim(),
                )
                .as_str(),
            );
        }
    }

    filters_all = filters_all.trim().to_string();

    filters_toc.push('\n');

    (filters_all, filters_toc, individual_sections)
}

struct UblockTagProcessor;

impl Preprocessor for UblockTagProcessor {
    fn name(&self) -> &str {
        "ublockfilters"
    }

    fn run(&self, _: &PreprocessorContext, mut book: Book) -> mdbook::errors::Result<Book> {
        let (filters_all, filters_toc, filters_sections) = parse_ublock_filters();
        book.for_each_mut(|bookitem| {
            if let BookItem::Chapter(chapter) = bookitem {
                chapter.content = chapter
                    .content
                    .replace(
                        "{{#ublockfilters-all}}",
                        format!("```adblock\n{}\n```", filters_all.as_str()).as_str(),
                    )
                    .replace("{{#ublockfilters-toc}}", filters_toc.as_str())
                    .replace("{{#ublockfilters}}", filters_sections.as_str());
            }
        });
        Ok(book)
    }
}

fn handle_processing(pre: &dyn Preprocessor) -> Result<(), Box<dyn Error>> {
    let (ctx, book) = CmdPreprocessor::parse_input(io::stdin())?;
    let processed_book = pre.run(&ctx, book).unwrap();
    serde_json::to_writer(io::stdout(), &processed_book)?;

    Ok(())
}

fn is_supported(pre: &dyn Preprocessor, sub_args: &ArgMatches) -> bool {
    let renderer = sub_args
        .get_one::<String>("renderer")
        .expect("Required argument");
    pre.supports_renderer(renderer)
}

fn make_app() -> Command {
    Command::new("ublockfilters-preprocessor")
        .about("A mdbook preprocessor which loads my uBlock Origin filters into the page, and generates a filter list which can be subscribed to.")
        .subcommand(
            Command::new("supports")
                .arg(Arg::new("renderer").required(true))
                .about("Check whether a renderer is supported by this preprocessor"),
        ).subcommand(Command::new("gen-filter-list").arg(
            Arg::new("path").required(true)
        ).about("Generate ublock-filters.txt list that can be subscribed to."))
}

fn main() -> Result<(), Box<dyn Error>> {
    let matches = make_app().get_matches();

    let preprocessor = UblockTagProcessor {};

    if let Some(sub_args) = matches.subcommand_matches("supports") {
        process::exit(if is_supported(&preprocessor, sub_args) {
            0
        } else {
            1
        });
    } else if let Some(sub_args) = matches.subcommand_matches("gen-filter-list") {
        let path = sub_args
            .get_one::<String>("path")
            .expect("required argument");
        let (filters_all, _, _) = parse_ublock_filters();
        let mut writer = std::fs::OpenOptions::new()
            .create(true)
            .write(true)
            .truncate(true)
            .open(path)?;
        writer.write_all(filters_all.as_bytes())?;
    } else if let Err(e) = handle_processing(&preprocessor) {
        eprintln!("{}", e);
        process::exit(1);
    }
    Ok(())
}

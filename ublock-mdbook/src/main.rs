use clap::{Arg, ArgMatches, Command};
use mdbook::{
    book::Book,
    preprocess::{CmdPreprocessor, Preprocessor, PreprocessorContext},
    BookItem,
};
use regex::Regex;
use std::{collections::HashMap, error::Error, io, process};

fn parse_ublock_filters() -> (String, String, String) {
    let filters = serde_yaml::from_str::<Vec<HashMap<String, String>>>(include_str!(
        "../../conf.d/ublock-filters.yml"
    ))
    .unwrap();

    let md_linkify_pattern = Regex::new(r"[^A-Za-z]").unwrap();

    let mut filters_toc = String::from("");
    let mut filters_all = String::from("```adblock\n");
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
            filters_all.push_str(format!("{}\n\n", filters_text.trim()).as_str());
        }
    }

    filters_all = filters_all.trim().to_string();
    filters_all.push_str("\n```");

    filters_toc.push('\n');

    (filters_all, filters_toc, individual_sections)
}

struct UblockTagProcessor;

impl Preprocessor for UblockTagProcessor {
    fn name(&self) -> &str {
        "ublockfilters"
    }

    fn run(&self, _: &PreprocessorContext, mut book: Book) -> mdbook::errors::Result<Book> {
        book.for_each_mut(|bookitem| {
            let (filters_all, filters_toc, filters_sections) = parse_ublock_filters();
            if let BookItem::Chapter(chapter) = bookitem {
                chapter.content = chapter
                    .content
                    .replace("{{#ublockfilters-all}}", filters_all.as_str())
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

fn handle_supports(pre: &dyn Preprocessor, sub_args: &ArgMatches) -> ! {
    let renderer = sub_args
        .get_one::<String>("renderer")
        .expect("Required argument");
    let supported = pre.supports_renderer(renderer);

    // Signal whether the renderer is supported by exiting with 1 or 0.
    if supported {
        process::exit(0);
    } else {
        process::exit(1);
    }
}

fn make_app() -> Command {
    Command::new("nop-preprocessor")
        .about("A mdbook preprocessor which loads my uBlock Origin filters into the page.")
        .subcommand(
            Command::new("supports")
                .arg(Arg::new("renderer").required(true))
                .about("Check whether a renderer is supported by this preprocessor"),
        )
}

fn main() -> Result<(), Box<dyn Error>> {
    let matches = make_app().get_matches();

    let preprocessor = UblockTagProcessor {};

    if let Some(sub_args) = matches.subcommand_matches("supports") {
        handle_supports(&preprocessor, sub_args);
    } else if let Err(e) = handle_processing(&preprocessor) {
        eprintln!("{}", e);
        process::exit(1);
    }
    Ok(())
}

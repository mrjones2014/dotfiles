require('my.utils.lsp').on_attach(function(client, bufnr)
  if client.name ~= 'graphql' or vim.bo[bufnr].ft ~= 'graphql' then
    return
  end

  ---@type integer?
  local result_buf
  local spinner_frames = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }

  local function get_or_create_result_win()
    if result_buf and vim.api.nvim_buf_is_valid(result_buf) then
      local win = vim.fn.bufwinid(result_buf)
      if win ~= -1 then
        vim.api.nvim_set_current_win(win)
      else
        vim.cmd('vsplit')
        vim.api.nvim_win_set_buf(0, result_buf)
      end
      vim.bo[result_buf].modifiable = true
      vim.api.nvim_buf_set_lines(result_buf, 0, -1, false, {})
      return vim.api.nvim_get_current_win()
    end

    vim.cmd('vnew')
    result_buf = vim.api.nvim_get_current_buf()
    vim.bo[result_buf].buftype = 'nofile'
    vim.bo[result_buf].bufhidden = 'hide'
    vim.bo[result_buf].swapfile = false
    vim.b[result_buf].graphql_output = true
    return vim.api.nvim_get_current_win()
  end

  local function execute_query()
    local query = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n')

    local function run(url)
      local prev_win = vim.api.nvim_get_current_win()
      local result_win = get_or_create_result_win()
      vim.api.nvim_set_current_win(prev_win)

      local frame = 0
      local timer = assert(vim.uv.new_timer())
      timer:start(
        0,
        80,
        vim.schedule_wrap(function()
          if not vim.api.nvim_win_is_valid(result_win) then
            timer:stop()
            timer:close()
            return
          end
          frame = (frame + 1) % #spinner_frames
          vim.wo[result_win].winbar = ' ' .. spinner_frames[frame + 1] .. ' Executing query...'
        end)
      )

      local json_body = vim.json.encode({ query = query })
      vim.system(
        { 'curl', '-s', '-X', 'POST', '-H', 'Content-Type: application/json', '-d', json_body, url },
        { text = true },
        vim.schedule_wrap(function(result)
          timer:stop()
          timer:close()

          if not result_buf or not vim.api.nvim_buf_is_valid(result_buf) then
            return
          end

          local win = vim.fn.bufwinid(result_buf)
          if win ~= -1 then
            vim.wo[win].winbar = ''
          end

          local output
          if result.code ~= 0 then
            output = 'Error: curl exited with code ' .. result.code .. '\n' .. (result.stderr or '')
          else
            local ok, decoded = pcall(vim.json.decode, result.stdout)
            if ok then
              output = vim.json.encode(decoded)
              -- pretty print via jq if available
              local jq = vim.system({ 'jq', '.' }, { stdin = output, text = true }):wait()
              if jq.code == 0 then
                output = jq.stdout
              end
            else
              output = result.stdout
            end
          end

          vim.bo[result_buf].modifiable = true
          vim.api.nvim_buf_set_lines(result_buf, 0, -1, false, vim.split(output or '', '\n'))
          vim.bo[result_buf].modifiable = false
          vim.bo[result_buf].filetype = 'json'
        end)
      )
    end

    local endpoint = vim.g.graphql_endpoint
    if endpoint and endpoint ~= '' then
      run(endpoint)
    else
      vim.ui.input({ prompt = 'GraphQL endpoint: ' }, function(input)
        if not input or input == '' then
          return
        end
        vim.g.graphql_endpoint = input
        run(input)
      end)
    end
  end

  require('which-key').add({
    { '<leader>e', execute_query, desc = 'Execute GraphQL query', buffer = bufnr },
  })
end)

return {
  cmd = { 'graphql-lsp', 'server', '-m', 'stream' },
  filetypes = { 'graphql', 'javascriptreact', 'typescriptreact' },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    on_dir(vim.fs.root(fname, { '.graphqlrc', '.graphqlrc.yml', '.graphqlrc.yaml', '.graphql.config.json' }))
  end,
}

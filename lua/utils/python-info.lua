local M = {}

local function buffer_dir(bufnr)
    local file = vim.api.nvim_buf_get_name(bufnr)
    if file ~= "" then
        return vim.fs.dirname(file), file
    end

    return vim.fn.getcwd(), nil
end

local function run_python(python, args)
    local cmd = { python }
    vim.list_extend(cmd, args)

    local output = vim.fn.systemlist(cmd)
    local ok = vim.v.shell_error == 0

    return ok, table.concat(output, "\n")
end

local function python_version(python)
    local ok, output = run_python(python, {
        "-c",
        "import sys; print(sys.version.split()[0])",
    })

    return ok and output ~= "" and output or "unavailable"
end

local function module_status(python, module)
    local ok, output = run_python(python, {
        "-c",
        table.concat({
            "import importlib.metadata as metadata",
            "import importlib.util",
            "import sys",
            "module = sys.argv[1]",
            "if importlib.util.find_spec(module) is None:",
            "    sys.exit(1)",
            "try:",
            "    print(metadata.version(module))",
            "except metadata.PackageNotFoundError:",
            "    print('available')",
        }, "\n"),
        module,
    })

    if not ok then
        return "no"
    end

    return output ~= "" and ("yes (" .. output .. ")") or "yes"
end

local function lsp_clients(bufnr, name)
    if vim.lsp.get_clients then
        return vim.lsp.get_clients({ bufnr = bufnr, name = name })
    end

    return vim.lsp.get_active_clients({ bufnr = bufnr, name = name })
end

local function basedpyright_info(bufnr)
    local clients = lsp_clients(bufnr, "basedpyright")
    if #clients == 0 then
        return { "basedpyright: not attached" }
    end

    local lines = {}
    for _, client in ipairs(clients) do
        local config = client.config or {}
        local python_path = vim.tbl_get(config, "settings", "python", "pythonPath") or "unavailable"
        local root_dir = config.root_dir or client.root_dir or "unavailable"

        table.insert(lines, "basedpyright: attached")
        table.insert(lines, "basedpyright root: " .. root_dir)
        table.insert(lines, "basedpyright pythonPath: " .. python_path)
    end

    return lines
end

function M.show()
    local bufnr = vim.api.nvim_get_current_buf()
    local dir, file = buffer_dir(bufnr)
    local python = require("utils.venv").resolve_python(dir)
    local local_venv = python.source == "nearby local venv" and "yes" or "no"
    local lines = {
        "PythonInfo",
        "buffer: " .. (file or "[No file buffer]"),
        "directory: " .. dir,
        "interpreter: " .. python.path,
        "source: " .. python.source,
        "local venv active: " .. local_venv,
        "python version: " .. python_version(python.path),
        "black: " .. module_status(python.path, "black"),
        "isort: " .. module_status(python.path, "isort"),
        "debugpy: " .. module_status(python.path, "debugpy"),
    }

    vim.list_extend(lines, basedpyright_info(bufnr))
    vim.api.nvim_echo({ { table.concat(lines, "\n"), "Normal" } }, true, {})
end

function M.setup()
    vim.api.nvim_create_user_command("PythonInfo", function()
        M.show()
    end, {
        desc = "Show resolved Python environment information for the current buffer",
    })
end

return M

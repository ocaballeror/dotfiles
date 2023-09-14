from pathlib import Path

exec(Path("~/.config/ptpython/config.py").expanduser().read_text())
main = configure

def configure(repl):
    main(repl)

    repl.paste_mode = True

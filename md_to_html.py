from pathlib import Path
import markdown2

PATH_FILE_TO_CONVERT = Path('./README.md')
PATH_OUTPUT = Path('./README.html')

md = markdown2.markdown(PATH_FILE_TO_CONVERT.read_text(), extras=['tables'])
PATH_OUTPUT.touch()
PATH_OUTPUT.write_text(md)

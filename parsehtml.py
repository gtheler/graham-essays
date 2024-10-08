import sys
import html2text
from bs4 import BeautifulSoup

# breakpoint()
h = html2text.HTML2Text()
h.ignore_images = True
h.ignore_tables = True
h.escape_all = True
h.reference_links = True
h.mark_code = True

soup = BeautifulSoup(sys.stdin.read(), "html.parser")
td_cells = soup.select("table > tr > td > table > tr > td")
print(td_cells[0])

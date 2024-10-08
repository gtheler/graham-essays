from bs4 import BeautifulSoup

articles = open("articles.html", "r")
soup = BeautifulSoup(articles, "html.parser")
# Find all relevant 'td' elements
td_cells = soup.select("table > tr > td > table > tr > td")
chapter_links = []
for td in td_cells:
  # use the heuristic that page links are an <a> inside a <font> with a small (bullet) image alongside
  img = td.find("img")
  if img and int(img.get("width", 0)) <= 15 and int(img.get("height", 0)) <= 15:
    a_tag = td.find("font").find("a") if td.find("font") else None
    if a_tag and not "http" in a_tag["href"]:
      print(a_tag["href"], a_tag.text)

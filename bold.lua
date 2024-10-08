function Span(el)
  if el.classes:includes('b') then
    return pandoc.Strong(el.content)
  end
end

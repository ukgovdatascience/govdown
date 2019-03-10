local List = require 'pandoc.List'

function Header(el)
  local level = el.level
  local identifier = el.attr.identifier
  local caption_text = el.attributes["caption"]
  local content = el.content
  local header_text

  if level == 1 then
    size = "xl"
  elseif level == 2 then
    size = "l"
  elseif level == 3 then
    size = "m"
  elseif level == 4 then
    size = "s"
  end

  if caption_text ~= nil and level <= 3 then
    header_text = {pandoc.Span(caption_text, pandoc.Attr("", {"govuk-caption-" .. size}))}

    -- concatenate the content after the caption to have one list of caption
    -- and then content.
    for _, v in pairs(content) do
        table.insert(header_text, v)
    end
  else
    header_text = content
  end

  local header =
    pandoc.Header(
      level,
      header_text,
      pandoc.Attr("", {"govuk-heading-" .. size})
    )

  return header
end

-- Apply govuk-body to everything within a para by wrapping it in a span,
-- because pandoc doesn't allow attributes of paras.
function Para(el)
  content = el.content
  attr = pandoc.Attr("", {"govuk-body"})
  return pandoc.Para(pandoc.Span(content, attr))
end

-- Hyperlinks
function Link(el)
  el.classes:extend({"govuk-link"})
  return el
end

-- Code blocks
function CodeBlock(el)
  el.classes:extend({"app-tabs__container js-tabs__container"})
  return el
end

-- Inset Text
function BlockQuote(el)
  return pandoc.Div(el.content, pandoc.Attr("", {"govuk-inset-text"}))
end

function BulletList(items)
  local res = List:new{pandoc.RawBlock('html', '<ul class="govuk=list govuk-list--bullet">')}
  for _, item in ipairs(items.content) do
    res[#res + 1] = pandoc.RawBlock('html', '<li class="govuk-body">')
    res:extend(item)
    res[#res + 1] = pandoc.RawBlock('html', '</li>')
  end
  res[#res + 1] = pandoc.RawBlock('html', '</ul>')
  return res
end

function OrderedList(items)
  local res = List:new{pandoc.RawBlock('html', '<ol class="govuk-list govuk-list--number">')}
  for _, item in ipairs(items.content) do
    res[#res + 1] = pandoc.RawBlock('html', '<li class="govuk-body">')
    res:extend(item)
    res[#res + 1] = pandoc.RawBlock('html', '</li>')
  end
  res[#res + 1] = pandoc.RawBlock('html', '</ol>')
  return res
end

function HorizontalRule()
  return pandoc.RawBlock('html', '<hr class="govuk-section-break govuk-section-break--xl govuk-section-break--visible">')
end

function Div(el)
  -- Deal with fenced divs

  -- Lead paragraphs
  local para_to_lead = {
    -- List of one function to be walked over paras within lead-para divs,
    -- replacing govuk-body with govuk-body-l.
    Span = function (el)
      v,i = el.classes:find("govuk-body")
      if i ~= nil then
        el.classes[i] = "govuk-body-l"
      end
      return el
    end
  }
  -- Look for 'lead-para'
  v,i = el.classes:find("lead-para")
  if i ~= nil then
    el.classes[i] = "govuk-body-l"
    -- replace govuk-body with govuk-body-l in child paras
    return pandoc.walk_block(el, para_to_lead)
  end

  -- Small paragraphs
  local para_to_small = {
    -- List of one function to be walked over paras within small-para divs,
    -- replacing govuk-body with govuk-body-s.
    Span = function (el)
      v,i = el.classes:find("govuk-body")
      if i ~= nil then
        el.classes[i] = "govuk-body-s"
      end
      return el
    end
  }
  -- Look for 'small-para'
  v,i = el.classes:find("small-para")
  if i ~= nil then
    el.classes[i] = "govuk-body-s"
    -- replace govuk-body with govuk-body-l in child paras
    return pandoc.walk_block(el, para_to_small)
  end

  return el
end

-- Preserve raw html
function html(text)
    return pandoc.RawInline("html", text)
end

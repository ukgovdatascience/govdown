local List = require 'pandoc.List'

return {

  {
    -- Deal with fenced divs
    Div = function(el)

      -- Look for 'breadcrumbs'
      v,i = el.classes:find("breadcrumbs")
      if i ~= nil then
        el.classes[i] = "govuk-breadcrumbs"

        el = pandoc.walk_block(el, {
            -- Breadcrumb BulletList
            BulletList = function (items)
              local res = List:new{
                pandoc.RawBlock('html', '<ol class="govuk-breadcrumbs__list">')
              }
              for _, item in ipairs(items.content) do
                res[#res + 1] = pandoc.RawBlock('html', '<li class="govuk-breadcrumbs__list-item">')
                res:extend(item)
                res[#res + 1] = pandoc.RawBlock('html', '</li>')
              end
              res[#res + 1] = pandoc.RawBlock('html', '</ol>')
              return res
            end
        })

        el = pandoc.walk_block(el, {
          -- Breadcrumb Hyperlinks
          Link = function(el)
            el.classes:extend({"govuk-breadcrumbs__link"})
            return el
          end
        })

        return el
      end

      -- Look for 'unbulleted-list'
      v,i = el.classes:find("unbulleted-list")
      if i ~= nil then
        el.classes[i] = nil
        return pandoc.walk_block(el, {
          -- Breadcrumb BulletList
          BulletList = function (items)
            local res = List:new{pandoc.RawBlock('html', '<ul class="govuk-list">')}
            for _, item in ipairs(items.content) do
              res[#res + 1] = pandoc.RawBlock('html', '<li>')
              res:extend(item)
              res[#res + 1] = pandoc.RawBlock('html', '</li>')
            end
            res[#res + 1] = pandoc.RawBlock('html', '</ul>')
            return res
          end
        })
      end

      -- Look for 'lead-para'
      v,i = el.classes:find("lead-para")
      if i ~= nil then
        el.classes[i] = nil
        -- Apply govuk-body to everything within a para by wrapping it in a span,
        -- because pandoc doesn't allow attributes of paras.
        return pandoc.walk_block(el, {
          Para = function(el)
            content = el.content
            attr = pandoc.Attr("", {"govuk-body-l"})
            return pandoc.Para(pandoc.Span(content, attr))
          end
        })
      end

      -- Look for 'small-para'
      v,i = el.classes:find("small-para")
      if i ~= nil then
        el.classes[i] = nil
        -- Apply govuk-body to everything within a para by wrapping it in a span,
        -- because pandoc doesn't allow attributes of paras.
        return pandoc.walk_block(el, {
          Para = function(el)
            content = el.content
            attr = pandoc.Attr("", {"govuk-body-s"})
            return pandoc.Para(pandoc.Span(content, attr))
          end
        })
      end

      return el
    end
  },

  {
    Header = function(el)
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
  },

  {
    -- Apply govuk-body to everything within a para by wrapping it in a span,
    -- because pandoc doesn't allow attributes of paras.
    Para = function(el)
      content = el.content
      attr = pandoc.Attr("", {"govuk-body"})
      return pandoc.Para(pandoc.Span(content, attr))
    end
  },

  {
    -- Hyperlinks
    Link = function(el)
      el.classes:extend({"govuk-link"})
      v,i = el.classes:find("no-visited-state")
      if i ~= nil then
        el.classes[i] = "govuk-link--no-visited-state"
      end
      return el
    end
  },

  {
    -- Code blocks
    CodeBlock = function (el)
      el.classes:extend({"app-tabs__container js-tabs__container"})
      return el
    end
  },

  {
    -- Inset text
    BlockQuote = function(el)
      return pandoc.Div(el.content, pandoc.Attr("", {"govuk-inset-text"}))
    end
  },

  {
    -- Section break
    HorizontalRule = function()
      return pandoc.RawBlock('html', '<hr class="govuk-section-break govuk-section-break--xl govuk-section-break--visible">')
    end
  },

  {
    -- Normal BulletList
    BulletList = function(items)
      local res = List:new{pandoc.RawBlock('html', '<ul class="govuk=list govuk-list--bullet">')}
      for _, item in ipairs(items.content) do
        res[#res + 1] = pandoc.RawBlock('html', '<li class="govuk-body">')
        res:extend(item)
        res[#res + 1] = pandoc.RawBlock('html', '</li>')
      end
      res[#res + 1] = pandoc.RawBlock('html', '</ul>')
      return res
    end
  },

  {
    -- Numbered list
    OrderedList = function(items)
      local res = List:new{pandoc.RawBlock('html', '<ol class="govuk-list govuk-list--number">')}
      for _, item in ipairs(items.content) do
        res[#res + 1] = pandoc.RawBlock('html', '<li class="govuk-body">')
        res:extend(item)
        res[#res + 1] = pandoc.RawBlock('html', '</li>')
      end
      res[#res + 1] = pandoc.RawBlock('html', '</ol>')
      return res
    end
  },

  -- Preserve raw html
  html = function(text)
    return pandoc.RawInline("html", text)
  end

}

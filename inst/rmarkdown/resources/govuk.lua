local List = require 'pandoc.List'

-- -- https://gist.github.com/liukun/f9ce7d6d14fa45fe9b924a3eed5c3d99
-- -- see also https://gist.github.com/liukun/f9ce7d6d14fa45fe9b924a3eed5c3d99

-- function encodeURI(str)
--   if (str) then
--     str = string.gsub (str, "\n", "\r\n")
--     str = string.gsub (str, "([^%w ])",
--       function (c) return string.format ("%%%02X", string.byte(c)) end)
--     str = string.gsub (str, " ", "+")
--   end
--   return str
-- end

-- function decodeURI(s)
--   if(s) then
--     s = string.gsub(s, "+", " ")
--     s = string.gsub(s, '%%(%x%x)',
--       function (hex) return string.char(tonumber(hex,16)) end )
--   end
--   return s
-- end

return {

  {
    -- Deal with fenced divs
    Div = function(el)

       -- look for details
      v,i = el.classes:find("details")
      if i ~= nil then
        el.classes[i] = nil

        local html
        local res = List:new{}

        html =
          '<details class="govuk-details">' ..
          '<summary class="govuk-details__summary">' ..
          '<span class="govuk-details__summary-text">'..
          pandoc.utils.stringify(el.attributes["summary"]) ..
          '</span>'..
          '</summary>' ..
          '<div class="govuk-details__text">'

        table.insert(res, pandoc.RawBlock('html', html))

        for _, block in pairs(el.content) do
          table.insert(res, block)
        end
        table.insert(res, pandoc.RawBlock('html', '</div>'))
        table.insert(res, pandoc.RawBlock('html', '</details>'))

        return res
      end

      -- Look for 'tabset'
      v,i = el.classes:find("tabset")
      if i ~= nil then
        el.classes[i] = nil
        el.classes:extend({"govuk-tabs"})
        el.attributes = {{"data-module", "tabs"}}

        -- begin items
        -- iterate over blocks
        -- if header
        --   if level 1
        --     set as title at level 2
        --   elseif level 2
        --     add to items
        --     if not first level 2 header
        --       close previous section
        --     begin new section
        --   else
        --     add to section
        -- else
        --   add to section
        -- end
        -- close items and sections
        -- combine title, items and sections

        local title
        local items = List:new{}
        local sections = List:new{}
        local html
        local first_section = true

        -- items[#items] = pandoc.RawBlock('html', '<ul class="govuk-tabs__list">')
        table.insert(items, pandoc.RawBlock('html', '<ul class="govuk-tabs__list">'))

        for _, block in pairs(el.content) do
          if block.t == "Header" then
            if block.level == 1 then
              -- set title
              block.level = 2
              block.classes:extend({"govuk-tabs__title"})
              title = block
            elseif block.level == 2 then
              -- add new item
              html =
                '<li class="govuk-tabs__list-item">' ..
                '<a class="govuk-tabs__tab govuk-tabs__tab--selected" href="#' ..
                block.identifier ..
                '">' ..
                pandoc.utils.stringify(block.content) ..
                '</a>'
              table.insert(items, pandoc.RawBlock('html', html))
              if first_section then
                first_section = false
              else
                -- Close previous section
                table.insert(sections, pandoc.RawBlock('html', "</section>"))
              end
              -- Open  new section
              html =
                '<section class="govuk-tabs__panel" id="' ..
                block.identifier ..
                '">'
              table.insert(sections, pandoc.RawBlock('html', html))
              -- Put header in section, but disguise it as not-a-header so that
              -- pandoc doesn't give it an id attribute, otherwise browsers will
              -- scroll to it, pushing the tab titles above the screen edge.
              html =
                '<h2 class="govuk-heading-l">' ..
                pandoc.utils.stringify(block.content) ..
                '</h2>'
              table.insert(sections, pandoc.RawBlock('html', html))
            end
          else
            table.insert(sections, block)
          end
        end

        -- close items and sections
        table.insert(items, pandoc.RawBlock('html', '</ul>'))
        table.insert(sections, pandoc.RawBlock('html', "</section>"))

        -- combine title, items and sections
        el.content = List:new{}

        table.insert(el.content, title)

        for _, v in pairs(items) do
          table.insert(el.content, v)
        end

        for _, v in pairs(sections) do
          table.insert(el.content, v)
        end

        return el

      end

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
                table.insert(res, pandoc.RawBlock('html', '<li class="govuk-breadcrumbs__list-item">'))
                res:extend(item)
                table.insert(res, pandoc.RawBlock('html', '</li>'))
              end
              table.insert(res, pandoc.RawBlock('html', '</ol>'))
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
              table.insert(res, pandoc.RawBlock('html', '<li>'))
              res:extend(item)
              table.insert(res, pandoc.RawBlock('html', '</li>'))
            end
            table.insert(res, pandoc.RawBlock('html', '</ul>'))
            return res
          end
        })
      end

      -- Look for 'lead-para'
      v,i = el.classes:find("lead-para")
      if i ~= nil then
        el.classes[i] = nil
        -- Construct a fake para because pandoc doesn't allow attributes of
        -- paras.
        return pandoc.walk_block(el, {
          Para = function(el)
            res = List:new{}
            res:extend({pandoc.RawBlock('html', '<p class="govuk-body-l">')})
            res:extend({pandoc.Plain(el.content)})
            res:extend({pandoc.RawBlock('html', '</p>')})
            return res
          end
        })
      end

      -- Look for 'small-para'
      v,i = el.classes:find("small-para")
      if i ~= nil then
        el.classes[i] = nil
        -- Construct a fake para because pandoc doesn't allow attributes of
        -- paras.
        return pandoc.walk_block(el, {
          Para = function(el)
            res = List:new{}
            res:extend({pandoc.RawBlock('html', '<p class="govuk-body-s">')})
            res:extend({pandoc.Plain(el.content)})
            res:extend({pandoc.RawBlock('html', '</p>')})
            return res
          end
        })
      end

      return el
    end
  },

  {
    Header = function(el)
      local level = el.level
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
        el.attributes["caption"] = nil
        header_text = {pandoc.Span(caption_text, pandoc.Attr("", {"govuk-caption-" .. size}))}

        -- concatenate the content after the caption to have one list of caption
        -- and then content.
        for _, v in pairs(content) do
          table.insert(header_text, v)
        end
      else
        header_text = content
      end

      el.content = header_text
      if el.classes ~= nil then
        el.classes:extend({"govuk-heading-" .. size})
      else
        el.classes = {"govuk-heading-" .. size}
      end
      return el

    end
  },

  {
    -- Construct a fake para because pandoc doesn't allow attributes of paras.
    Para = function(el)
      res = List:new{}
      res:extend({pandoc.RawBlock('html', '<p class="govuk-body">')})
      res:extend({pandoc.Plain(el.content)})
      res:extend({pandoc.RawBlock('html', '</p>')})
      return res
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
        table.insert(res, pandoc.RawBlock('html', '<li class="govuk-body">'))
        res:extend(item)
        table.insert(res, pandoc.RawBlock('html', '</li>'))
      end
      table.insert(res, pandoc.RawBlock('html', '</ul>'))
      return res
    end
  },

  {
    -- Numbered list
    OrderedList = function(items)
      local res = List:new{pandoc.RawBlock('html', '<ol class="govuk-list govuk-list--number">')}
      for _, item in ipairs(items.content) do
        table.insert(res, pandoc.RawBlock('html', '<li class="govuk-body">'))
        res:extend(item)
        table.insert(res, pandoc.RawBlock('html', '</li>'))
      end
      table.insert(res, pandoc.RawBlock('html', '</ol>'))
      return res
    end
  }
}

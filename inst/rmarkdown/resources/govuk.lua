local List = require 'pandoc.List'
local accordion_id = 0


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
          '<details class="govuk-details" data-module="govuk-details">' ..
          '<summary class="govuk-details__summary">' ..
          '<span class="govuk-details__summary-text">'..
          el.attributes["summary"] ..
          '</span>'..
          '</summary>' ..
          '<div class="govuk-details__text">'

        table.insert(res, pandoc.RawBlock('html', html))

        for _, block in ipairs(el.content) do
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
        el.attributes = {{"data-module", "govuk-tabs"}}

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

        for _, block in ipairs(el.content) do
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

        for _, v in ipairs(items) do
          table.insert(el.content, v)
        end

        for _, v in ipairs(sections) do
          table.insert(el.content, v)
        end

        return el

      end

      -- Look for 'accordion'
      v,i = el.classes:find("accordion")
      if i ~= nil then
        accordion_id = accordion_id + 1
        el.classes[i] = nil
        el.classes:extend({"govuk-accordion"})
        el.attributes = {{"data-module", "govuk-accordion"}, {"id", "accordion-1"}}

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
        -- close sections

        local sections = List:new{}
        local html
        local first_section = true
        local section_id = 0

        for _, block in ipairs(el.content) do
          if block.t == "Header" then
            if block.level == 2 then
              section_id = section_id + 1
              -- add new item
              html =
                '<div class="govuk-accordion__section">\n' ..
                '<div class="govuk-accordion__section-header">\n' ..
                '<h2 class="govuk-accordion__section-heading">\n' ..
                '<span class="govuk-accordion__section-button" id="accordion-' ..
                accordion_id ..
                '-heading-' ..
                section_id ..
                '">\n' ..
                pandoc.utils.stringify(block.content) ..
                '\n</span>\n' ..
                '</h2>\n' ..
                '</div>\n' ..
                '<div id="accordion-' .. accordion_id .. '-content-' .. section_id .. '" class="govuk-accordion__section-content" aria-labelledby="accordion-' .. accordion_id .. '-heading-' .. section_id .. '">'
              if first_section then
                first_section = false
              else
                -- Close previous section
                table.insert(sections, pandoc.RawBlock('html', "</div></div>"))
              end
              -- Open new section
              table.insert(sections, pandoc.RawBlock('html', html))
            end
          else
            table.insert(sections, block)
          end
        end

        -- close everything
        table.insert(sections, pandoc.RawBlock('html', "</div></div>"))

        -- replace element content
        el.content = List:new{}

        for _, v in ipairs(sections) do
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

      -- Look for 'warning'
      v,i = el.classes:find("warning")
      if i ~= nil then
        el.classes[i] = nil

        local html
        local res = List:new{}

        html =
          '<div class="govuk-warning-text">' ..
          '<span class="govuk-warning-text__icon" aria-hidden="true">!</span>' ..
          '<strong class="govuk-warning-text__text">'..
          '<span class="govuk-warning-text__assistive">Warning</span>'

        table.insert(res, pandoc.RawBlock('html', html))

        for _, block in ipairs(el.content) do
          table.insert(res, pandoc.Plain(block.content))
        end

        table.insert(res, pandoc.RawBlock('html', '</strong>'))
        table.insert(res, pandoc.RawBlock('html', '</div>'))

        return res
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
        for _, v in ipairs(content) do
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
    -- Bold
    Strong = function(el)
      return pandoc.Span(el.content, pandoc.Attr("", {"govuk-!-font-weight-bold"}))
    end
  },

  {
    -- Disable italics
    Emph = function(el)
      return el.content
    end
  },

  {
    -- Disable strike-through
    Strikeout = function(el)
      return el.content
    end
  },

  {
    -- Disable italics
    Emph = function(el)
      return el.content
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
    -- Table
    Table = function(el)
      local res = List:new{} -- list of blocks
      table.insert(res, pandoc.RawBlock('html', '<table class="govuk-table">'))

      local caption = List:new{} -- list of inlines
      caption:extend({pandoc.RawInline('html', '<caption class="govuk-table__caption">')})
      for _, item in ipairs(el.caption) do
        table.insert(caption, item)
      end
      caption:extend({pandoc.RawInline('html', '</caption>')})
      table.insert(res, pandoc.Plain(caption))


      if el.headers ~= nil then
        table.insert(res, pandoc.RawBlock('html', '<thead class="govuk-table__head">'))
        table.insert(res, pandoc.RawBlock('html', '<tr class="govuk-table__row">'))
        local i = 0
        local alignment = ""
        for _, item in ipairs(el.headers) do
          i = i + 1
          if el.aligns[i] == "AlignRight" then
            table.insert(res, pandoc.RawBlock('html', '<th class="govuk-table__header govuk-table__header--numeric" scope="col">'))
          else
            table.insert(res, pandoc.RawBlock('html', '<th class="govuk-table__header" scope="col">'))
          end
          res:extend(item)
          table.insert(res, pandoc.RawBlock('html', '</th>'))
        end
        table.insert(res, pandoc.RawBlock('html', '</tr>'))
        table.insert(res, pandoc.RawBlock('html', '</thead>'))
      end

      if el.rows ~= nil then
        table.insert(res, pandoc.RawBlock('html', '<tbody class="govuk-table__body">'))
        for _, row in ipairs(el.rows) do
          table.insert(res, pandoc.RawBlock('html', '<tr class="govuk-table__row">'))
          local i = 0
          for _, cell in ipairs(row) do
            i = i + 1
            if el.aligns[i] == "AlignRight" then
              table.insert(res, pandoc.RawBlock('html', '<td class="govuk-table__cell govuk-table__cell--numeric">'))
            else
              table.insert(res, pandoc.RawBlock('html', '<td class="govuk-table__cell">'))
            end
            res:extend(cell)
            table.insert(res, pandoc.RawBlock('html', '</td>'))
          end
          table.insert(res, pandoc.RawBlock('html', '</tr>'))
        end
        table.insert(res, pandoc.RawBlock('html', '</tbody>'))
      end

      table.insert(res, pandoc.RawBlock('html', '</table>'))
      return res
    end
  },

  {
    -- Normal BulletList
    BulletList = function(items)
      local res = List:new{pandoc.RawBlock('html', '<ul class="govuk-list govuk-list--bullet">')}
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
  },

  {
    CodeBlock = function(el)
      if el.classes[1] == nil then
          el.classes[1] = "plaintext"
      end
      return el
    end
  }
}

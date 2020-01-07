-- from https://github.com/a-vrma/pandoc-filters/blob/master/src/standard-code.lua
-- via https://github.com/jgm/pandoc/issues/3858

-- Turns <pre class="*"><code> into <pre><code class="language-*".
-- Throws away all attributes, so it should come after any filters that use attributes.

local function escape(s, in_attribute)
  -- escape according to html5 rules
  return s:gsub(
    '[<>&"\']',
    function(x)
      if x == '<' then
        return '&lt;'
      elseif x == '>' then
        return '&gt;'
      elseif x == '&' then
        return '&amp;'
      elseif x == '"' then
        return '&quot;'
      elseif x == "'" then
        return '&#39;'
      else
        return x
      end
    end
  )
end

local function getCodeClass(classes)
  -- check if classes includes a programming language name. Side effect is that it
  -- removes the class that matches from the `classes` table
  -- returns: Valid class attr using first match (with a space at beginning).
  --          or empty string if no classes match a programming language name.
  local classIndex = -1

  for i, cl in ipairs(classes) do
    return ' class="language-' .. table.remove(classes, i) .. '"'
  end
  return ''
end

local function makeIdentifier(ident)
  -- returns: valid id attr (with a space at the beginning) OR empty string
  if #ident ~= 0 then
    return ' id="'.. ident .. '"'
  else
    return ''
  end
end

local function makeClasses(classes)
  -- returns valid class attr with classes separated by spaces (with a space at
  -- the beginning) OR empty string.
  if #classes ~= 0 then
    return ' class="' .. table.concat(classes, " ") .. '"'
  else
    return ''
  end
end

return {
  {
    CodeBlock = function(p)

      id = makeIdentifier(p.identifier)
      classLang = getCodeClass(p.classes)
      classReg = makeClasses(p.classes)

      local pre_code = string.format(
        '<pre%s%s%s><code%s>%s</code></pre>', id, classLang, classReg, classLang, escape(p.text)
      )
      return pandoc.RawBlock('html', pre_code ,'RawBlock')
    end,

  }
}

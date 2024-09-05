require('luasnip.session.snippet_collection').clear_snippets('javascript')

local ls = require('luasnip')

ls.add_snippets('javascript', {
  ls.parser.parse_snippet('ibb', "import Bluebird from 'bluebird';"),
  ls.parser.parse_snippet('ir', "import React from 'react';"),
  ls.parser.parse_snippet('icn', "import cn from 'lib/classnames';"),
  ls.parser.parse_snippet('ild', "import { ${0:} } from 'lodash';"),
  ls.parser.parse_snippet('iui', "import { ${0:} } from 'ui';"),
  ls.parser.parse_snippet('ii', "import ${1:} from '${0:}';"),
  ls.parser.parse_snippet('it', "import { describe, expect, test } from 'bun:test';"),
  ls.parser.parse_snippet('cl', 'console.log(${0:});'),
  ls.parser.parse_snippet('js', 'JSON.stringify(${0:}, null, 2)'),
  ls.parser.parse_snippet('rsa', 'Record<string, any>'),
  ls.parser.parse_snippet('rss', 'Record<string, string>'),
  ls.parser.parse_snippet('rsu', 'Record<string, ${0:}>'),
  ls.parser.parse_snippet('uS', 'const [${0:}] = useState();'),
  ls.parser.parse_snippet('uR', 'const [${0:}, dispatch] = useReducer();'),
  ls.parser.parse_snippet('uE', 'useEffect(() => {\n\t${0:}\n}, []);'),
  ls.parser.parse_snippet('uLE', 'useLayoutEffect(() => {\n\t${0:}\n}, []);'),
  ls.parser.parse_snippet('uC', 'useCallback(() => {\n\t${0:}\n}, []);'),
  ls.parser.parse_snippet('uM', 'useMemo(() => {\n\t${0:}\n}, []);'),
  ls.parser.parse_snippet('prom', 'new Promise((resolve, reject) => {\n\t${0:}\n});'),
  ls.parser.parse_snippet('delay', 'await new Promise((resolve, reject) => setTimeout(resolve, 2000));'),
  ls.parser.parse_snippet('cn', 'className="${0:}"'),
  ls.parser.parse_snippet('cnn', 'className={cn(``, {\n\t${0:}\n})}'),
  ls.parser.parse_snippet('ctx', 'const ctx = useHydrationContext();'),
  ls.parser.parse_snippet('tx', 'await LIBS.sequelize.transaction(async (t) => {\n\t${0:}\n});'),
  ls.parser.parse_snippet('/**', '/**\n * ${0:}\n */'),
})

ls.filetype_extend('typescript', { 'javascript' })
ls.filetype_extend('javascriptreact', { 'javascript' })
ls.filetype_extend('typescriptreact', { 'javascript' })
ls.filetype_extend('astro', { 'javascript' })

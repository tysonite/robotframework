from ast import AST
import re


class Node(AST):
    _fields = ()

    def _add_joiners(self, values):
        for index, item in enumerate(values):
            yield item
            if index < len(values) - 1:
                yield self._joiner_based_on_eol_escapes(item)

    def _joiner_based_on_eol_escapes(self, item):
        _end_of_line_escapes = re.compile(r'(\\+)n?$')
        match = _end_of_line_escapes.search(item)
        if match and len(match.group(1)) % 2 == 1:
            return ''
        return '\n'


class Value(Node):
    _fields = ('value',)

    def __init__(self, value):
        self.value = value


class DataFile(Node):
    _fields = ('sections',)

    def __init__(self, sections):
        self.sections = sections


class SettingSection(Node):
    _fields = ('settings',)

    def __init__(self, settings):
        self.settings = settings


class VariableSection(Node):
    _fields = ('variables',)

    def __init__(self, variables):
        self.variables = variables


class TestCaseSection(Node):
    _fields = ('tests',)

    def __init__(self, tests, header):
        self.tests = tests
        self.header = header[0].strip("*").strip()


class KeywordSection(Node):
    _fields = ('keywords',)

    def __init__(self, keywords):
        self.keywords = keywords


class Variable(Node):
    _fields = ('name', 'value')

    def __init__(self, name, value):
        self.name = name
        self.value = value


class KeywordCall(Node):
    # TODO: consider `keyword` -> `name`, as in Fixture
    _fields = ('assign', 'keyword', 'args')

    def __init__(self, assign, keyword, args=None):
        self.assign = assign or ()
        self.keyword = keyword
        self.args = args or ()


class ForLoop(Node):
    _fields = ('variables', 'flavor', 'values', 'body')

    def __init__(self, variables, flavor, values, body=None):
        self.variables = variables
        self.flavor = flavor
        self.values = values
        self.body = body or []


class TestCase(Node):
    _fields = ('name', 'body')

    def __init__(self, name, body):
        self.name = name
        self.body = body


class Keyword(Node):
    _fields = ('name', 'body')

    def __init__(self, name, body):
        self.name = name
        self.body = body


class TemplateArguments(Node):
    _fields = ('args',)

    def __init__(self, args):
        self.args = args


class ImportSetting(Node):
    _fields = ('name', 'args')

    def __init__(self, name, args):
        self.name = name
        self.args = args


class LibrarySetting(ImportSetting): pass
class ResourceSetting(ImportSetting): pass
class VariablesSetting(ImportSetting): pass


class MetadataSetting(Node):
    _fields = ('name', 'value')

    def __init__(self, name, value):
        self.name = name
        self.value = ''.join(self._add_joiners(value))


class DocumentationSetting(Value):

    def __init__(self, value):
        doc = ''.join(self._add_joiners(value))
        Value.__init__(self, doc)


class Fixture(Node):
    _fields = ('name', 'args')

    def __init__(self, value):
        if value and value[0].upper() != 'NONE':
            self.name = value[0]
            self.args = tuple(value[1:])
        else:
            self.name = None
            self.args = ()


class SuiteSetupSetting(Fixture): pass
class SuiteTeardownSetting(Fixture): pass
class TestSetupSetting(Fixture): pass
class TestTeardownSetting(Fixture): pass
class SetupSetting(Fixture): pass
class TeardownSetting(Fixture): pass


class TestTemplateSetting(Value):

    def __init__(self, value):
        value = value[0] if value and value[0].upper() != 'NONE' else None
        Value.__init__(self, value)


class TemplateSetting(TestTemplateSetting): pass


class TestTimeoutSetting(Value): pass
class ForceTagsSetting(Value): pass
class DefaultTagsSetting(Value): pass
class TimeoutSetting(Value): pass
class TagsSetting(Value): pass
class ArgumentsSetting(Value): pass
class ReturnSetting(Value): pass

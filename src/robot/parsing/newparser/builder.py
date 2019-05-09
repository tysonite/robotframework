import os

from robot.errors import DataError
from robot.output import LOGGER
from robot.parsing.vendor import yacc
from robot.parsing.lexer import TestCaseFileLexer, ResourceFileLexer
from robot.utils import Utf8Reader

from .nodes import TestCaseSection
from .parser import RobotFrameworkParser


def get_test_case_file_ast(source):
    lexer = TestCaseFileLexer()
    parser = yacc.yacc(module=RobotFrameworkParser())
    return parser.parse(lexer=LexerWrapper(lexer, source))


def get_resource_file_ast(source):
    lexer = ResourceFileLexer()
    parser = yacc.yacc(module=RobotFrameworkParser())
    ast = parser.parse(lexer=LexerWrapper(lexer, source))
    if any(isinstance(s, TestCaseSection) for s in ast.sections):
        raise DataError("Resource file '%s' cannot contain tests or tasks." % source)
    return ast


class LexerWrapper(object):

    def __init__(self, lexer, source):
        self.source = source
        self.curdir = os.path.dirname(source).replace('\\', '\\\\')
        lexer.input(Utf8Reader(source).read())
        self.tokens = lexer.get_tokens()

    def token(self):
        token = next(self.tokens, None)
        # print(repr(token))
        if token and token.type == token.ERROR:
            self._report_error(token)
            return self._next_token_after_eos()
        if token and '${CURDIR}' in token.value:
            token.value = token.value.replace('${CURDIR}', self.curdir)
        return token

    def _report_error(self, token):
        # TODO: add line number
        LOGGER.error("Error in file '%s': %s" % (self.source, token.error))

    def _next_token_after_eos(self):
        while True:
            token = self.token()
            if token is None:
                return None
            if token.type == token.EOS:
                return self.token()

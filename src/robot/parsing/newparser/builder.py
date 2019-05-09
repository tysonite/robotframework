import os

from robot.output import LOGGER
from robot.parsing.vendor import yacc
from robot.parsing.lexer import RobotFrameworkLexer
from robot.utils import Utf8Reader

from .parser import RobotFrameworkParser


class Builder(object):

    def read(self, source):
        data = Utf8Reader(source).read()
        parser = yacc.yacc(module=RobotFrameworkParser())
        return parser.parse(lexer=LexerWrapper(data, source))


class LexerWrapper(object):

    def __init__(self, data, source):
        self.source = source
        self.curdir = os.path.dirname(source).replace('\\', '\\\\')
        lexer = RobotFrameworkLexer(data_only=True)
        lexer.input(data)
        self.tokens = lexer.get_tokens()

    def token(self):
        token = next(self.tokens, None)
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
        token = self.token()
        while token.type != token.EOS:
            token = self.token()
        return self.token()

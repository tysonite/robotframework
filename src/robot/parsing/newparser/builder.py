import os

from robot.utils import Utf8Reader
from robot.parsing.vendor import yacc
from robot.parsing.lexer import RobotFrameworkLexer

from .parser import RobotFrameworkParser


class Builder(object):

    def read(self, source):
        data = Utf8Reader(source).read()
        parser = yacc.yacc(module=RobotFrameworkParser())
        return parser.parse(lexer=LexerWrapper(data))


class LexerWrapper(object):

    def __init__(self, data, source):
        self.curdir = os.path.dirname(source).replace('\\', '\\\\')
        lexer = RobotFrameworkLexer(data_only=True)
        lexer.input(data)
        self.tokens = lexer.get_tokens()

    def token(self):
        token = next(self.tokens, None)
        if token and '${CURDIR}' in token.value:
            token.value = token.value.replace('${CURDIR}', self.curdir)
        return token

#  Copyright 2008-2015 Nokia Networks
#  Copyright 2016-     Robot Framework Foundation
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

import os

from robot.errors import DataError
from robot.output import LOGGER
from robot.utils import Utf8Reader

from .lexer import TestCaseFileLexer, ResourceFileLexer
from .nodes import TestCaseSection
from .parser import RobotFrameworkParser
from .vendor import yacc


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

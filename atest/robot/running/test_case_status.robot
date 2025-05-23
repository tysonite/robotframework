*** Settings ***
Documentation     Tests for setting test case status correctly when test passes
...               and when a failure or error occurs. Also includes test cases
...               for running test setup and teardown in different situations.
Suite Setup       Run Tests    ${EMPTY}    running/test_case_status.robot
Resource          atest_resource.robot

*** Test Cases ***
Test Passes
    Check Test Case    ${TEST NAME}

Test Fails
    Check Test Case    ${TEST NAME}

Non-Existing Keyword Error
    Check Test Case    ${TEST NAME}

Test Setup Passes
    Check Test Case    ${TEST NAME}

Test Setup Fails
    [Documentation]    Checks also that test is not run if setup fails
    Check Test Case    ${TEST NAME}

Test Setup Error
    Check Test Case    ${TEST NAME}

Test Teardown Passes
    Check Test Case    ${TEST NAME}

Test Teardown Fails
    Check Test Case    ${TEST NAME}

Test Teardown Error
    Check Test Case    ${TEST NAME}

Test And Teardown Fails
    Check Test Case    ${TEST NAME}

Test Setup And Teardown Pass
    Check Test Case    ${TEST NAME}

Test Teardown is Run When Setup Fails
    ${tc} =    Check Test Case    ${TEST NAME}
    Should Not Be Equal    ${tc.teardown}         ${None}    Teardown not run    No values
    Length Should Be       ${tc.teardown.body}    1
    Check Log Message      ${tc.teardown[0]}      Hello from teardown!

Test Setup And Teardown Fails
    Check Test Case    ${TEST NAME}

robot.api.Failure
    Check Test Case    ${TEST NAME}

robot.api.Failure with HTML message
    Check Test Case    ${TEST NAME}

robot.api.Error
    Check Test Case    ${TEST NAME}

robot.api.Error with HTML message
    Check Test Case    ${TEST NAME}

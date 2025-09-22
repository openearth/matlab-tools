%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Unit tests for extract_data_line function

classdef test_extract_data_line < matlab.unittest.TestCase
    

    methods(Test)
        function testNumbersAndStrings(testCase)
            line = '20 ''crs_4_01'' -0.4  , , , , , -0.35  0.045  \ ignore';
            [nums, strs] = extract_data_line(line);

            expectedNums = [20 NaN -0.4 NaN NaN NaN NaN -0.35 0.045];
            expectedStrs = {'', 'crs_4_01', '', '', '', '', '', '', ''};

            testCase.verifyEqual(nums, expectedNums);
            testCase.verifyEqual(strs, expectedStrs);
        end

        function testEmptyLine(testCase)
            [nums, strs] = extract_data_line('');
            testCase.verifyEmpty(nums);
            testCase.verifyEmpty(strs);
        end

        function testNumbersOnly(testCase)
            line = '1, 2.5, -3, 4e-2';
            [nums, strs] = extract_data_line(line);
            expectedNums = [1 2.5 -3 0.04];
            expectedStrs = {'', '', '', ''};
            testCase.verifyEqual(nums, expectedNums);
            testCase.verifyEqual(strs, expectedStrs);
        end

        function testQuotedNumbers(testCase)
            line = '''1.5'', ''text'', 2';
            [nums, strs] = extract_data_line(line);
            expectedNums = [NaN NaN 2];
            expectedStrs = {'1.5', 'text', ''};
            testCase.verifyEqual(nums, expectedNums);
            testCase.verifyEqual(strs, expectedStrs);
        end

        function testOnlyEmptySlots(testCase)
            line = ', , ,';
            [nums, strs] = extract_data_line(line);
            expectedNums = [NaN NaN NaN NaN];
            expectedStrs = {'', '', '', ''};
            testCase.verifyEqual(nums, expectedNums);
            testCase.verifyEqual(strs, expectedStrs);
        end

        function testIgnoreBackslash(testCase)
            line = '5, ''keep'' \ ignore this';
            [nums, strs] = extract_data_line(line);
            expectedNums = [5 NaN];
            expectedStrs = {'', 'keep'};
            testCase.verifyEqual(nums, expectedNums);
            testCase.verifyEqual(strs, expectedStrs);
        end

        function testIgnoreBackslashDouble(testCase)
            line = '0.   0.  // $NOEdiff_AW01$          // FOP - NOEdiff_AW01';
            [nums, strs] = extract_data_line(line);
            expectedNums = [0 0];
            expectedStrs = {'', ''};
            testCase.verifyEqual(nums, expectedNums);
            testCase.verifyEqual(strs, expectedStrs);
        end
        
    end
end
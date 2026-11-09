function tests=test_gdb_read_variables_file
tests=functiontests(localfunctions);
end

function testRealTypeFormats(testCase)
values=[12523863.333103318;23863.333103317767;-7409.2358047277767; ...
    16237081.164116737;16205808.595208693;31272.568908045545;zeros(34,1)];
types={'REAL(8)','REAL*8'};
numbers=[312,6];
for kt=1:numel(types)
    for kv=1:2
        if kv==1
            expected=values;
        else
            expected=zeros(40,1);
        end
        text=sprintf('m_flow::voltot\ntype = %s (40)\n$%d = (%s)\n', ...
            types{kt},numbers(kt),strjoin(arrayfun(@(x)sprintf('%.17g',x), ...
            expected,'UniformOutput',false),', '));
        data=read_text(text);
        verifyEqual(testCase,data.m_flow.voltot,expected);
    end
end
end

function testAllocatableReal(testCase)
expected=[0.047061126544493126;0.047136215966549183;0.048465559609920411; ...
    0.047247493431428159;0.048493856271271618;0.049839564512532283; ...
    0.047377331135816929;0.048577490255374778;0.049882536402538785];
types={'REAL*8, allocatable','REAL(8), allocatable'};
for kt=1:numel(types)
    text=sprintf('m_flow::s1\ntype = %s (9)\n$1 = (%s)\n', ...
        types{kt},strjoin(arrayfun(@(x)sprintf('%.17g',x), ...
        expected,'UniformOutput',false),', '));
    data=read_text(text);
    verifyEqual(testCase,data.m_flow.s1,expected);
end
end

function testDimensionsAndOtherTypes(testCase)
text=sprintf(['m_flow::matrix\ntype = REAL*8 (0:1,3)\n$1 = ((1, 2) (3, 4) (5, 6))\n' ...
    'm_flow::count\ntype = INTEGER(4)\n$2 = 7\n' ...
    'm_flow::enabled\ntype = LOGICAL(4)\n$3 = .TRUE.\n' ...
    'm_flow::label\ntype = character*100 (2)\n$4 = ignored\n']);
data=read_text(text);
verifyEqual(testCase,data.m_flow.matrix,[1,3,5;2,4,6]);
verifyEqual(testCase,data.m_flow.count,7);
verifyEqual(testCase,data.m_flow.enabled,true);
verifyEqual(testCase,data.m_flow.label,NaN(2,1));
end

function data=read_text(text)
fpath=tempname;
fid=fopen(fpath,'w');
assert(fid~=-1,'Could not create temporary GDB output file.');
file_cleanup=onCleanup(@()delete(fpath));
close_cleanup=onCleanup(@()fclose(fid));
fprintf(fid,'%s',text);
clear close_cleanup
data=gdb_read_variables_file(fpath);
end

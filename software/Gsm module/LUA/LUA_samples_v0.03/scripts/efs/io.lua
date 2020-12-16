--------------------------------------------------------------------------------
--����˵��
--���ű������ļ���д���ܣ������ı���ʽ�Ͷ����Ʒ�ʽ
--1. ��ģ��/MultiMedia/Picture/�·�һ��ͼƬnormal.jpg
--------------------------------------------------------------------------------
function io_test_file_content(filepath)
  print("begin to read file content:", filepath,"\r\n")
  local file = io.open(filepath,"r");
  assert(file)
  local cnt = nil;
  filelen = 0;
  while (true) do
  --if (true) then
    cnt = file:read(1024);
    if (not cnt) then       
      break;
    else
      filelen = filelen + string.len(cnt);
      print("read cnt suc, total_len\t=",filelen,"\r\n");
    end;
    vmsleep(0);
  end;
  file:close();
  print("finished reading file content, total_len\t=",filelen,"\r\n");
end

-------------------------------------------------------------------
--CONFIGURATION SECTION
test_loop_count = 1;
-------------------------------------------------------------------
printdir(1)

count = 0;
while (count < test_loop_count) do
  count = count + 1;
  print("-------------------run count=",count,"\r\n");
  print("1. test file:write()\r\n")
  file = io.open("c:\\test1.txt","w");
  assert(file)
  file:trunc();
  file:write("test content\r\ntest\r\ntest result\r\nhello");
  file:close();
  
  print("2. test file:read(*a)\r\n")
  file = io.open("c:\\test1.txt","r");
  assert(file)
  cnt = file:read("*a");
  print(cnt, "\r\n")
  file:close();
  
  print("3. test file:lines()\r\n")
  file = io.open("c:\\test1.txt","r");
  assert(file)
  for line in file:lines() do
  print("line content = ", line, "\r\n");
  end
  file:close();
  
  print("4. test file:read(*l)\r\n")
  file = io.open("c:\\test1.txt","r");
  assert(file)
  cnt = file:read("*l");
  print(cnt, "\r\n")
  cnt = file:read("*l");
  print(cnt, "\r\n")
  cnt = file:read("*l");
  print(cnt, "\r\n")
  
  
  filepath="c:\\Picture\\normal.jpg";
  io_test_file_content(filepath);
  file:close();
  print("\r\n");
end;
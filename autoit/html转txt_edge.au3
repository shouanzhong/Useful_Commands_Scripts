#include <File.au3>
#include <Array.au3>
#include <MsgBoxConstants.au3>

; 定义要遍历的目录
Local $directory = "D:\ProgramFiles\M01_M01_R26_GDPR\data\localfile\GDPR\APP-OS商业化应用\Phone Master"

; 调用函数遍历目录
TraverseDirectory($directory)

; 遍历目录函数
Func TraverseDirectory($dir)
    ; 获取目录中的所有文件和文件夹
    Local $fileList = _FileListToArray($dir, "*", $FLTA_FILESFOLDERS, True)
    If @error Then
        MsgBox($MB_ICONERROR, "错误", "无法读取目录: " & $dir)
        Return
    EndIf

    ; 遍历所有文件和文件夹
    For $i = 1 To $fileList[0]
        Local $fullPath = $fileList[$i]
        If StringInStr(FileGetAttrib($fullPath), "D") Then
            ; 如果是文件夹，递归遍历
            TraverseDirectory($fullPath)
        Else
            ; 如果是文件，检查是否是 .html 文件
            If StringLower(StringRight($fullPath, 5)) = ".html" Then
                ; 处理 .html 文件
                ProcessHtmlFile($fullPath)

;~                 ; 弹窗询问用户是否继续
;~                 Local $response = MsgBox($MB_YESNO, "提示", "已转换文件: " & $fullPath & @CRLF & "是否继续转换下一个文件？")
;~                 If $response = $IDNO Then
;~                     Exit ; 用户选择停止，退出整个脚本
;~                 EndIf
            EndIf
        EndIf
    Next
EndFunc

; 处理 .html 文件函数
Func ProcessHtmlFile($filePath)
    ; 打开 .html 文件
    ShellExecute($filePath)
    WinWaitActive("[CLASS:Chrome_WidgetWin_1]") ; 等待 Edge 窗口激活
    Sleep(2000) ; 等待文件完全加载

    ; 模拟快捷键 Ctrl+A 全选内容
    Send("^a")
    Sleep(500)

    ; 模拟快捷键 Ctrl+C 复制内容
    Send("^c")
    Sleep(500)

    ; 关闭 Edge 窗口
    WinClose("[CLASS:Chrome_WidgetWin_1]")
    Sleep(1000)

    ; 获取剪贴板内容
    Local $clipboardText = ClipGet()
    If @error Then
        MsgBox($MB_ICONERROR, "错误", "无法获取剪贴板内容: " & $filePath)
        Return
    EndIf

    ; 删除特定字符串（例如 "xxxx"）
    $clipboardText = StringReplace($clipboardText, "    ", "") ; 


    ; 生成 .txt 文件路径
    Local $txtFilePath = StringReplace($filePath, ".html", ".txt")

    ; 将内容写入 .txt 文件
    Local $fileHandle = FileOpen($txtFilePath, 2 + 8) ; 2 = 覆盖模式, 8 = UTF-8 编码
    If $fileHandle = -1 Then
        MsgBox($MB_ICONERROR, "错误", "无法创建文件: " & $txtFilePath)
        Return
    EndIf
    FileWrite($fileHandle, $clipboardText)
    FileClose($fileHandle)

    ; 打印日志（解决中文乱码问题）
    Local $logMessage = "已转换文件: " & $txtFilePath
    FileWriteLine(@ScriptDir & "\log.txt", $logMessage) ; 将日志写入文件
EndFunc
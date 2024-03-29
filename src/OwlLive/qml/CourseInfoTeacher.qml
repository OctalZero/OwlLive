﻿import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import FluentUI 1.0
import Controller 1.0

FluScrollablePage{
    id: window
    leftPadding:10
    rightPadding:0
    bottomPadding:20

    property var coursePageRegister: registerForPageResult("/createCourse")
    property var courses: []
    property string courseId: ""
    property bool isTeacher

    LoginController {
        id: login_controller
    }

    Component.onCompleted: {
        if (login_controller.getIdentification() === "teacher") {
            isTeacher = true
            course_controller.SendUpdateCourses();
        }
        else {
            isTeacher = false
            showError("当前账户身份为学生，暂无使用该功能权限！")
        }
    }

    // 更新界面的课程列表
    function updateList() {
        for (var i = 0; i < courses.length; i++) {
            var course = courses[i]
            if (course["status"]) {
                addCourse(course["name"], "上课中", course["master"], course["id"])
            }
            else {
                addCourse(course["name"], "未上课", course["master"], course["id"])
            }
        }
    }

    CourseController {
        id: course_controller
        onUpdateCoursesSuccess: {
            if (isTeacher) {
                courses = course_controller.getCourses()  // 存储课程列表
                model_course.clear() // 清空原来的课程
                updateList()
            }
        }

//        onJoinClassSuccess: {
//            if (isTeacher) {
//                FluApp.navigate("/live", {courseId:courseId, streamAddress:course_controller.getStreamAddress()})
//            }
//        }
    }

    // 从创建课程界面获取返回数据
    Connections{
        target: coursePageRegister
        function onResult(data)
        {
            course_controller.SendCreateInfo(data.courseName)
        }
    }


    // 添加课程
    function addCourse(name, state, master, id) {
        model_course.append({"name": name, "state": state, "master": master, "id": id})
    }

    // 获取选中课程的流地址
//    function getStreamUrl(id) {
//        for (var i = 0; i < courses.length; i++) {
//            var course = courses[i]
//            if (course["id"] === id) {
//                return course["stream_address"];
//            }
//        }
//    }

    FluFilledButton {
        id: create_course
        disabled: !isTeacher
        text: "创建课程"
        onClicked:  {
            coursePageRegister.launch()
        }
    }

    // 课程卡
    Component {
        id: course_card
        Item {
            id: course_item
            width: 320
            height: 280
            FluArea {
                width: 300
                height: 260
                anchors.centerIn: parent

                ColumnLayout {
                    spacing: 17
                    anchors {
                        left: parent.left
                        top: parent.top
                        leftMargin: 20
                        topMargin: 20
                    }

                    FluText{
                        id: course_name
                        text: model.name
                        fontStyle: FluText.TitleLarge
                    }

                    FluText{
                        id: state
                        text: model.state
                        fontStyle: FluText.SubTitle
                    }

                    FluText{
                        id: master
                        text: "任课教师:" + model.master
                        fontStyle: FluText.BodyStrong
                    }

                    FluText{
                        id: course_id
                        text: "课程号:" + model.id
                        fontStyle: FluText.BodyStrong
                    }
                }

                RowLayout {
                    spacing: 58
                    anchors{
                        left: parent.left
                        bottom: parent.bottom
                        leftMargin: 20
                        bottomMargin: 20
                    }

                    FluFilledButton {
                        text: "开启课堂"
                        onClicked: {
                            courseId = model.id
                            course_controller.setCourseId(courseId)
                            FluApp.navigate("/live", {courseId:courseId})
                        }
                    }

                    FluFilledButton {
                        id: course_info
                        text: "课堂讨论"
                        onClicked: {
                            course_controller.setCourseId(model.id)
                        }
                    }
                }


                FluFilledButton {
                    id: over_course
                    text: "结课"
                    normalColor: "grey"
                    hoverColor: "#8B0000"
                    anchors{
                        right: parent.right
                        top: parent.top
                        rightMargin: 10
                        topMargin: 10
                    }
                    onClicked: {
                        course_controller.DeleteCourse(model.id)
                    }
                }
            }
        }
    }

    // 课程表模型
    ListModel {
        id: model_course
    }

    GridView{
        id: model_list
        Layout.fillWidth: true
        implicitHeight: contentHeight
        cellHeight: 280
        cellWidth: 320
        model: model_course
        interactive: false
        delegate: course_card
    }
}

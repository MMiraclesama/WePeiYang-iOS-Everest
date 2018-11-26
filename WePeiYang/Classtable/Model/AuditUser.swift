//
//  AuditUser.swift
//  WePeiYang
//
//  Created by 赵家琛 on 2018/11/21.
//  Copyright © 2018 twtstudio. All rights reserved.
//

import Foundation

class AuditUser {
    static var shared = AuditUser()
    private init() {}
    
    private var idDict: [Int : [Int]] = [:]
    private var originTable: ClassTableModel?
    var weekCourseDict: [Int: [[ClassModel]]] = [:]
    
    func deleteCourse(infoIDs: [Int], success: @escaping ([AuditDetailCourseItem]) -> Void, failure: @escaping (String) -> Void) {
        ClasstableDataManager.deleteAuditCourse(schoolID: self.schoolID, infoIDs: infoIDs, success: {
            ClasstableDataManager.getPersonalAuditList(success: { model in
//                infoIDs.forEach {
//                    self.idDict[$0] = nil
//                }
                
                var items: [AuditDetailCourseItem] = []
                model.data.forEach { list in
                    items += list.infos
                }
                AuditUser.shared.update(auditCourses: items)
                success(items)
            }, failure: { errStr in
                failure(errStr)
            })
        }, failure: { errStr in
            failure(errStr)
        })
    }
    
    func auditCourse(item: AuditDetailCourseItem, success: @escaping ([AuditDetailCourseItem]) -> Void, failure: @escaping (String) -> Void) {
        let courseID = item.courseID
        if let infoIDs = self.idDict[courseID] {
            if !infoIDs.contains(item.id) {
                self.idDict[courseID]!.append(item.id)
            }
        } else {
            self.idDict[courseID] = [item.id]
        }
        
        ClasstableDataManager.auditCourse(schoolID: self.schoolID, courseID: courseID, infoIDs: self.idDict[courseID]!, success: {
            ClasstableDataManager.getPersonalAuditList(success: { model in
                var items: [AuditDetailCourseItem] = []
                model.data.forEach { list in
                    items += list.infos
                }
                AuditUser.shared.update(auditCourses: items)
                success(items)
            }, failure: { errStr in
                failure(errStr)
            })
        }, failure: { errStr in
            failure(errStr)
        })
    }
    
    
    // 更新课程表
    func update(originTable table: ClassTableModel? = nil, auditCourses: [AuditDetailCourseItem] = []) {
        self.originTable = table ?? self.originTable
        
        self.idDict = [:]
        auditCourses.forEach { item in
            let courseID = item.courseID
            if let infoIDs = self.idDict[courseID] {
                if !infoIDs.contains(item.id) {
                    self.idDict[courseID]!.append(item.id)
                }
            } else {
                self.idDict[courseID] = [item.id]
            }
        }
        
        guard var table = self.originTable else {
            return
        }
        
        auditCourses.forEach { item in
            var auditCourse = ClassModel(JSONString: "{\"arrange\": [{\"day\": \"\(item.weekDay)\", \"start\":\"\(item.startTime)\", \"end\":\"\(item.startTime + item.courseLength - 1)\"}], \"isPlaceholder\": \"\(false)\"}")!
            if item.weekType == 1 {
                auditCourse.arrange[0].week = "单周"
            } else if item.weekType == 2 {
                auditCourse.arrange[0].week = "双周"
            } else if item.weekType == 3 {
                auditCourse.arrange[0].week = "单双周"
            }
            auditCourse.arrange[0].day = item.weekDay
            auditCourse.arrange[0].room = item.building + "楼" + item.room
            auditCourse.courseName = item.courseName
            auditCourse.weekStart = String(item.startWeek)
            auditCourse.weekEnd = String(item.endWeek)
            auditCourse.teacher = item.teacher + "  " + item.teacherType
            auditCourse.college = item.courseCollege
            auditCourse.courseID = String(-item.id)
            
            table.classes.append(auditCourse)
        }
        self.weekCourseDict = [:]
        for i in 1...22 {
            self.weekCourseDict[i] = self.getCourse(table: table, week: i)
        }
    }
    
    // 检查要蹭的课程是否有冲突
    func checkConflict(item: AuditDetailCourseItem) -> String? {
        for weekIndex in item.startWeek...item.endWeek {
            if (weekIndex % 2 == 0 && item.weekType == 1) || (weekIndex % 2 == 1 && item.weekType == 2) {
                continue
            }
            
            guard let coursesForDay = self.weekCourseDict[weekIndex] else {
                continue
            }
            
            let courseForSpecifiedDay = coursesForDay[item.weekDay - 1]
            for courseIndex in 0..<courseForSpecifiedDay.count {
                let course = courseForSpecifiedDay[courseIndex]
                guard course.isPlaceholder == false else {
                    continue
                }
                
                let startForCourse = course.arrange.first!.start
                let endForCourse = course.arrange.first!.end
                let startForItem = item.startTime
                let endForItem = item.startTime + item.courseLength - 1
                guard endForCourse < startForItem || startForCourse > endForItem else {
                    // 冲突了
                    if course.courseID == String(-item.id) {
                        return "[已蹭课]"
                    } else {
                        return course.courseName
                    }
                }
            }
        }
        return nil
    }
    
    var collegeDic: [Int : String] = [:]
    var schoolID: String {
        return TwTUser.shared.schoolID
    }
    
    func getCollegeName(ID: Int) -> String {
        if let name = self.collegeDic[ID] {
            return name
        } else {
            return ""
        }
    }
    
    func load() {
        ClasstableDataManager.getAllColleges(success: { model in
            model.data.forEach { item in
                self.collegeDic[item.collegeID] = item.collegeName
            }
        }, failure: { errStr in
            
        })
    }
    
    // MARK: - private
    private func getCourse(table: ClassTableModel, week: Int) -> [[ClassModel]] {
        if let dict = weekCourseDict[week] {
            return dict
        }
        // TODO: optimize
        
        var coursesForDay: [[ClassModel]] = [[], [], [], [], [], [], []]
        var classes = [] as [ClassModel]
        //        var coursesForDay: [[ClassModel]] = []
        for course in table.classes {
            // 对 week 进行判定
            // 起止周
            if week < Int(course.weekStart)! || week > Int(course.weekEnd)! {
                // TODO: turn gray
                continue
            }
            
            // 每个 arrange 变成一个
            for arrange in course.arrange {
                let day = arrange.day-1
                // 如果是实习什么的课
                if day < 0 || day > 6 {
                    continue
                }
                // 对 week 进行判定
                // 单双周
                if (week % 2 == 0 && arrange.week == "单周")
                    || (week % 2 == 1 && arrange.week == "双周") {
                    // TODO: turn gray
                    continue
                }
                
                var newCourse = course
                newCourse.arrange = [arrange]
                // TODO: 这个是啥来着?
                classes.append(newCourse)
                coursesForDay[day].append(newCourse)
            }
        }
        
        for day in 0..<7 {
            var array = coursesForDay[day]
            // 按课程开始时间排序
            array.sort(by: { a, b in
                return a.arrange[0].start < b.arrange[0].start
            })
            
            var lastEnd = 0
            for course in array {
                // 如果两节课之前有空格，加入长度为一的占位符
                if (course.arrange[0].start-1) - (lastEnd+1) >= 0 {
                    // 从上节课的结束到下节课的开始填满
                    for i in (lastEnd+1)...(course.arrange[0].start-1) {
                        // 构造一个假的 model
                        let placeholder = ClassModel(JSONString: "{\"arrange\": [{\"day\": \"\(course.arrange[0].day)\", \"start\":\"\(i)\", \"end\":\"\(i)\"}], \"isPlaceholder\": \"\(true)\"}")!
                        // placeholders[i].append(placeholder)
                        array.append(placeholder)
                    }
                }
                lastEnd = course.arrange[0].end
            }
            // 补下剩余的空白
            if lastEnd < 12 {
                for i in (lastEnd+1)...12 {
                    // 构造一个假的 model
                    let placeholder = ClassModel(JSONString: "{\"arrange\": [{\"day\": \"\(day)\", \"start\":\"\(i)\", \"end\":\"\(i)\"}], \"isPlaceholder\": \"\(true)\"}")!
                    array.append(placeholder)
                }
            }
            // 按开始时间进行排序
            array.sort(by: { $0.arrange[0].start < $1.arrange[0].start })
            coursesForDay[day] = array
        }
        self.weekCourseDict[week] = coursesForDay
        return coursesForDay
    }
}
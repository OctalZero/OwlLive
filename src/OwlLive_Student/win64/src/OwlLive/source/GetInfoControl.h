/*********************************************************************************
  *Date:  2022.06.19
  *Description:  获取信息控制类，
  *				 主要用于从实体类缓存中取出界面需要的信息，从而避免每次都向服务端索取信息。
**********************************************************************************/
#pragma once
#include <QObject>
class Student;

class GetInfoControl : public QObject
{
	Q_OBJECT
public:
	GetInfoControl();
	~GetInfoControl();

	// 解析想要查询的类型
	void ParseQueryType(const QJsonObject& data);
signals:
	// 返回信息查询结果的信号
	void QueryResult(const QJsonObject& data);

private:
	// 获取学生关联的所有课程的概要信息
	QJsonArray getCoursesAbstract();

	// 获取学生关联的所有课程的概要信息
	QJsonObject getClassInfo(const QString& course_id, const QString& class_id);

	// 解析并处理获取课程概要信息
	void ParseGetCoursesAbstract(const QJsonObject& data);

	// 解析并处理获取课堂信息
	void ParseGetClassInfo(const QJsonObject& data);
private:
	Student* student_ = nullptr;  // 学生相关的信息类
};

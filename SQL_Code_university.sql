SELECT name,
COUNT(CASE WHEN grade LIKE 'A%' THEN 1 END) as A,
COUNT(CASE WHEN grade LIKE 'B%' THEN 1 END) as B,
COUNT(CASE WHEN grade LIKE 'C%' THEN 1 END) as C,
COUNT(CASE WHEN grade LIKE 'D%' THEN 1 END) as D,
COUNT(CASE WHEN grade LIKE 'E%' THEN 1 END) as E,
COUNT(CASE WHEN grade LIKE 'F%' THEN 1 END) as F
FROM teaches
INNER JOIN instructor ON instructor.id=teaches.id
INNER JOIN takes ON teaches.course_id=takes.course_id 
AND teaches.sec_id=takes.sec_id 
AND teaches.semester=takes.semester
AND teaches.year=takes.year
GROUP BY name
ORDER BY A DESC, B DESC, C DESC, D DESC, E DESC, F DESC
;

CREATE VIEW hours_students_per_room AS
(WITH tot_hours_temp AS
(SELECT building, room_number, semester, year, course_id, sec_id,round(sum((end_hr*60 +end_min - (start_hr*60 + start_min))/60),1) AS tot_hours
FROM time_slot 
NATURAL JOIN takes
NATURAL JOIN section
GROUP BY semester, room_number, building, year, sec_id, course_id),
tot_student_temp AS 
(SELECT COUNT(id) as tot_student_no, tot_hours_temp.room_number, semester, year 
FROM takes NATURAL JOIN tot_hours_temp 
GROUP BY tot_hours_temp.room_number, takes.semester, takes.year)
SELECT building, tot_hours_temp.room_number, takes.semester, takes.year, tot_hours, tot_student_no
FROM tot_hours_temp
INNER JOIN tot_student_temp ON tot_hours_temp.semester=tot_student_temp.semester 
AND tot_hours_temp.year = tot_student_temp.year 
AND tot_student_temp.room_number = tot_hours_temp.room_number
INNER JOIN takes ON takes.course_id=tot_hours_temp.course_id 
AND takes.year=tot_hours_temp.year
AND takes.semester=tot_hours_temp.semester
AND takes.sec_id=tot_hours_temp.sec_id
GROUP BY building, tot_hours_temp.room_number, takes.semester, tot_hours, takes.year, tot_hours, tot_student_no)
;

CREATE VIEW schedule_per_department AS
(SELECT department.dept_name, title, teaches.semester, teaches.year, instructor.name, room_number, section.building, day, start_hr, start_min, end_hr, end_min
FROM department
INNER JOIN instructor ON department.dept_name = instructor.dept_name 
INNER JOIN teaches ON instructor.id = teaches.id
INNER JOIN section ON teaches.course_id = section.course_id AND section.sec_id=teaches.sec_id AND section.semester=teaches.semester AND section.year=teaches.year
INNER JOIN time_slot ON section.time_slot_id = time_slot.time_slot_id
INNER JOIN course ON course.course_id = teaches.course_id
ORDER BY department.dept_name, title, start_hr, day ASC)
;
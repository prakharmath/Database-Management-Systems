CREATE TABLE Student
(
   roll_no int not null,
   name varchar(30) not null,
   cgpa decimal(7,2) not null ,
   credits_cleared int not null 
);
CREATE TABLE Student_course
(
   roll_no int not null,
   course_cd char(2) not null,
   grade_point int not null
);
CREATE TABLE Course
(
   course_cd char(2) not null,
   course_name varchar(30) not null,
   credits int not null
);
CREATE TABLE Preqrequisite
(
   course_cd char(2) not null,
   prereq_course_cd char(2) not null
);
1a)
CREATE OR REPLACE TRIGGER MyTrigger
AFTER INSERT OR DELETE OR UPDATE ON Student_course
FOR EACH ROW
BEGIN
     if (INSERTING) THEN
         UPDATE Student
         SET S.credits_cleared=S.credits_cleared+C.credits
         FROM STUDENT S,Course C 
         WHERE S.roll_no=:NEW.roll_no and :NEW.course_cd=C.course_cd and :NEW.grade_point>=5
     elsif (DELETING) THEN
         UPDATE Student
         SET S.credits_cleared=S.credits_cleared-C.credits
         FROM STUDENT S,Course C 
         WHERE S.roll_no=:OLD.roll_no and :OLD.course_cd=C.course_cd and :NEW.grade_point>=5
     elsif (UPDATING) THEN
         UPDATE Student
         SET S.credits_cleared=S.credits_cleared-C.credits
         FROM STUDENT S,Course C 
         WHERE S.roll_no=:NEW.roll_no and :NEW.course_cd=C.course_cd and :NEW.grade_point>=5
     END IF;
END;
/
1b)
CREATE OR REPLACE TRIGGER MyTrigger
AFTER INSERT OR DELETE OR UPDATE ON Student_course
FOR EACH ROW
BEGIN
     if (INSERTING) THEN
         UPDATE Student
         SET S.credits_cleared=S.credits_cleared+C.credits
         FROM STUDENT S,Course C 
         WHERE S.roll_no=:NEW.roll_no and :NEW.course_cd=C.course_cd and :NEW.grade_point>=5
     elsif (DELETING) THEN
         UPDATE Student
         SET S.credits_cleared=S.credits_cleared-C.credits
         FROM STUDENT S,Course C 
         WHERE S.roll_no=:OLD.roll_no and :OLD.course_cd=C.course_cd and :NEW.grade_point>=5
     elsif (UPDATING) THEN
         UPDATE Student
         SET S.credits_cleared=S.credits_cleared-C.credits
         FROM STUDENT S,Course C 
         WHERE S.roll_no=:NEW.roll_no and :NEW.course_cd=C.course_cd and :NEW.grade_point>=5
     END IF;
END;
/        

2)
create or replace function get_cgpa (roll_no IN NUMBER)
    RETURN NUMBER IS temp_cgpa NUMBER(7, 2);
    BEGIN
            SELECT 
            	temp_cgpa_1 INTO temp_cgpa
            FROM 	
            	(
            		SELECT total_points/(1.0*(total_credits)) as temp_cgpa_1
            		FROM
        				(
            				SELECT sum(C.credits*SC.grade_point) as total_points, sum(C.credits) as total_credits
            				FROM Course C, Student_course SC
            				WHERE get_cgpa.roll_no=SC.roll_no and SC.course_cd=C.course_cd
            			)
            	) ;
        	UPDATE Student
        	SET Student.cgpa=temp_cgpa
        	WHERE Student.roll_no=get_cgpa.roll_no ;
        RETURN(temp_cgpa);
    END;
/		  
			

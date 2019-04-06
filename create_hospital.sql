drop database hospital;

create database hospital;
use hospital;

create table doctors (
	`doctor_id` int not null,
    `doctor_type` varchar(10) not null,
    `doctor_name` varchar(20) not null,
    `salary` int not null,
    CONSTRAINT `PK_doctor_id` PRIMARY KEY (`doctor_id`)
);

create table patients(
	`patient_id` int not null,
    `patient_name` varchar(20),
    CONSTRAINT `PK_patient_id` PRIMARY KEY (`patient_id`)
);

create table appointment (
	`appointment_id` int not null auto_increment, 
	`patient_id` int not null,
	`doctor_id` int not null,
	`appointment_time` datetime,
	CONSTRAINT `PK_appointment_id` PRIMARY KEY (`appointment_id`)
);

create table queue (
	`appointment_id` int not null,
    `actual_time` datetime,
	CONSTRAINT `PK_actual_time` PRIMARY KEY (`appointment_id`, `actual_time`)
 );
 
create table queue_summary (
	`date` datetime,
	`doctor_id` int,
	`num_of_patients` int,
    CONSTRAINT `PK_date_doctor_id` PRIMARY KEY (`date`, `doctor_id`)
 );
 
 


# ---------------------------------------------------------------------- #
# TRIGGER: After insert new appointment update queue                     #
# ---------------------------------------------------------------------- #
DELIMITER $$
CREATE TRIGGER queue_after_new_appointment
AFTER INSERT ON appointment
FOR EACH ROW
	BEGIN
		insert into queue values (new.appointment_id, new.appointment_time);
	END$$
DELIMITER ;

# ---------------------------------------------------------------------- #
# TRIGGER: After delete appointment from queue update queue summary      #
# ---------------------------------------------------------------------- #
DELIMITER $$
CREATE TRIGGER queue_summary_after_delete_from_queue
AFTER DELETE ON queue
FOR EACH ROW
	BEGIN
    
		declare removed_doctor int;
        declare removed_date datetime;
        declare count_of_patients int;
        
		select doctor_id into removed_doctor 
        from appointment as a left join queue as q on a.appointment_id = q.appointment_id
		where actual_time is null limit 1;
        
        select date(appointment_time) into removed_date 
        from appointment as a left join queue as q on a.appointment_id = q.appointment_id
		where actual_time is null limit 1;
	
        select num_of_patients into count_of_patients 
        from queue_summary 
        where (doctor_id = removed_doctor and date(`date`) = removed_date) limit 1;
        
		if ( count_of_patients = 1) then
			delete from queue_summary where doctor_id = removed_doctor and date(`date`) = removed_date;
        elseif ( count_of_patients > 1) then
			update queue_summary
			set num_of_patients = num_of_patients - 1
			where doctor_id = removed_doctor and date(`date`) = removed_date;
		end if;
        
        set removed_doctor = null;
        set removed_date = null;
        set count_of_patients = null;
	END$$
DELIMITER ;

# ---------------------------------------------------------------------- #
# TRIGGER: After insert appointment to queue update queue summary        #
# ---------------------------------------------------------------------- #
DELIMITER $$
CREATE TRIGGER queue_summary_after_insert_to_queue
AFTER INSERT ON queue
FOR EACH ROW
	BEGIN
		
        declare d_id int;
        declare new_date date;
        
        select a.doctor_id into d_id from appointment as a inner join doctors as d on a.doctor_id = d.doctor_id order by a.appointment_id desc limit 1;
        select date(new.actual_time) into new_date from queue limit 1;
    
		if (d_id in (select doctor_id from queue_summary as q where q.date = new_date)) then 
			update queue_summary
            set num_of_patients = num_of_patients + 1
            where (doctor_id = d_id  and `date` = new_date);
		else
			insert into queue_summary values (date(new_date), d_id, 1);
        end if;
        
        set d_id = null;
        set new_date = null;
	END$$
DELIMITER ;

# ---------------------------------------------------------------------- #
# PROCEDURE: Update to actual time, uses from java                       #
# ---------------------------------------------------------------------- #
DELIMITER $$
CREATE PROCEDURE `update_appointment_time`(in d_id int, in p_id int)
BEGIN
	update queue 
    set actual_time = NOW()
    where appointment_id = (
		select appointment_id
		from appointment as a
		where ( (a.doctor_id = d_id) and (a.patient_id = p_id) )
    );
END $$
DELIMITER ;

# ---------------------------------------------------------------------- #
# VIEW: View table                                                       #
# ---------------------------------------------------------------------- #
create view largest_waiting 
as select patient_name
from appointment as a inner join queue as q on a.appointment_id = q.appointment_id inner join patients as p on a.patient_id = p.patient_id
order by actual_time - appointment_time limit 10;


# ---------------------------------------------------------------------- #
# INSERT DATA TO HOSPITAL                                                #
# ---------------------------------------------------------------------- #

insert into Doctors values (999, "EKG", "moshe", 10000);
insert into Doctors values (888, "MRT", "menachem", 5000);
insert into Doctors values (777, "GYN", "osnat", 5000);

insert into Patients values (100, "alex");
insert into Patients values (111, "kobi");
insert into Patients values (199, "adar");
insert into Patients values (122, "yosi");
insert into Patients values (200, "herzel");
insert into Patients values (166, "hanna");
insert into Patients values (211, "dani");
insert into Patients values (188, "shira");
insert into Patients values (222, "or");
insert into Patients values (133, "alon");
insert into Patients values (177, "eden");
insert into Patients values (144, "shai");
insert into Patients values (233, "rahel");

insert into Appointment (patient_id, doctor_id, appointment_time) values (100, 999, '2019-03-19 13:00:00');
insert into Appointment (patient_id, doctor_id, appointment_time) values (111, 999, '2019-03-19 13:20:00');
insert into Appointment (patient_id, doctor_id, appointment_time) values (122, 888, '2019-03-15 10:00:00');
insert into Appointment (patient_id, doctor_id, appointment_time) values (133, 888, '2019-03-16 15:00:00');
insert into Appointment (patient_id, doctor_id, appointment_time) values (144, 999, '2019-03-19 14:30:00');
insert into Appointment (patient_id, doctor_id, appointment_time) values (155, 888, '2019-03-16 16:15:00');
insert into Appointment (patient_id, doctor_id, appointment_time) values (166, 999, '2019-03-19 15:45:00');
insert into Appointment (patient_id, doctor_id, appointment_time) values (177, 888, '2019-03-19 15:20:00');
insert into Appointment (patient_id, doctor_id, appointment_time) values (188, 999, '2019-03-19 12:00:00');
insert into Appointment (patient_id, doctor_id, appointment_time) values (199, 888, '2019-03-17 13:30:00');
insert into Appointment (patient_id, doctor_id, appointment_time) values (200, 777, '2019-03-18 13:10:00');
insert into Appointment (patient_id, doctor_id, appointment_time) values (211, 777, '2019-03-16 14:00:00');
insert into Appointment (patient_id, doctor_id, appointment_time) values (222, 777, '2019-03-16 10:30:00');
insert into Appointment (patient_id, doctor_id, appointment_time) values (233, 777, '2019-03-18 12:30:00');


use hospital;


# ---------------------------------------------------------------------- #
# part a.3                                                               #
# ---------------------------------------------------------------------- #
#select * from largest_waiting;

# ---------------------------------------------------------------------- #
# part a.4                                                               #
# ---------------------------------------------------------------------- #
#delete from queue where appointment_id = 6;
#delete from queue where appointment_id = 9;
#delete from queue where appointment_id = 11;


# ---------------------------------------------------------------------- #
# part b                                                                 #
# ---------------------------------------------------------------------- #
#select doctor_name, salary
#from doctors as d inner join queue_summary as q on d.doctor_id = q.doctor_id
#where num_of_patients >= 5 and date(`date`) = '2019-03-19';



package ex2;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class Main {

	public static void main(String[] args) {
		try{
			Class.forName("com.mysql.jdbc.Driver");
			try(Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hospital", "root", "root")){

				Statement stmt = con.createStatement();
				
				ResultSet rs = showListOfPationtsToDoctor(999, stmt); //first function
				
//				updateAppointmentTimeOfPatient(999, 111, con); //second function
//				rs = stmt.executeQuery("SELECT * FROM queue");


				int numOfColumns = rs.getMetaData().getColumnCount();
				while (rs.next()){
					for (int col = 1; col <= numOfColumns; col++){
						System.out.print(rs.getString(col) + " ");
					}
					System.out.println();
				}
			}} catch (Exception ex){
				System.err.println("Connection fails...");
			}
	}
	
	public static ResultSet showListOfPationtsToDoctor(int doctorId, Statement stmt) throws SQLException {
		String num = "" + doctorId;
		ResultSet rs = stmt.executeQuery("select a.patient_id, patient_name, appointment_time "
									   + "from appointment as a join patients as p on a.patient_id = p.patient_id "
									   + "where doctor_id = " + num + " "
									   + "order by appointment_time;");
		return rs;
	}
	
	public static void updateAppointmentTimeOfPatient(int doctor_id, int patient_id, Connection con) throws SQLException {
		String query = "call update_appointment_time(?, ?)";
		CallableStatement stmt = con.prepareCall(query);
		stmt.setInt(1, doctor_id);
		stmt.setInt(2, patient_id);
		stmt.executeQuery();
	}
}


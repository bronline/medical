<%-- 
    Document   : patientcheckin
    Created on : Mar 6, 2012, 7:54:53 AM
    Author     : rwandell
--%>

<%@include file="sessioninfo.jsp" %>
<%
    String visitQuery = "SELECT * FROM visits WHERE (`date` = current_date AND patientid = " + patient.getId() + ") ";
    int appointmentId = 0;
    int visitId = 0;

    PreparedStatement visitPs = io.getConnection().prepareStatement("INSERT INTO visits (appointmentid, patientid, `date`, locationid, timein, conditionid) VALUES(?,?,?,?,?,?)");
    PreparedStatement apptPs = io.getConnection().prepareStatement("update appointments set timein=? where id=?");

    ResultSet apptRs = io.opnRS("SELECT id, `date` AS apptdate FROM appointments WHERE patientid=" + patient.getId() + " AND `date`=current_date AND timein='0001-01-01 00:00:00'");

    if(apptRs.next()) {
        visitQuery += "OR appointmentid = " + apptRs.getInt("id");
        appointmentId = apptRs.getInt("id");
        apptPs.setString(1, Format.formatDate(new java.util.Date(), "yyyy-MM-dd hh:mm:ss"));
        apptPs.setInt(2, appointmentId);
        apptPs.execute();
    }

    ResultSet visitRs = io.opnRS(visitQuery);
    if(!visitRs.next()) {
        PatientConditions condition = new PatientConditions(io, 0);

        visitPs.setInt(1, appointmentId);
        visitPs.setInt(2, patient.getId());
        visitPs.setString(3, Format.formatDate(new java.util.Date(), "yyyy-MM-dd"));
        visitPs.setInt(4, 0);
        visitPs.setString(5, Format.formatDate(new java.util.Date(), "yyyy-MM-dd hh:mm:ss"));
        visitPs.setInt(6, condition.getCurrentCondition(""+patient.getId()));
        visitPs.execute();

        ResultSet rs  = io.opnRS("select LAST_INSERT_ID()");
        if(rs.next()) {
            visitId = rs.getInt(1);
            checkForPatientCopay(io, visitId, patient.getId());
        }
    }

    visitRs.close();
    apptRs.close();

%>
<%@include file="cleanup.jsp" %>
<%!
    public void checkForPatientCopay(RWConnMgr io, int visitId, int patientId) {
        try {
            ResultSet itmRs=io.opnRS("select * from items where copayitem");
            if(itmRs.next()) {
                ResultSet visitRs=io.opnRS("select * from charges where itemId=" + itmRs.getInt("id") + " and visitId=" + visitId);
                if(!visitRs.next()) {
                    String insuranceQuery="select * from patientinsurance as pi " +
                            "left join visits v on v.id=" + visitId + " " +
                            "left join patientconditions pc on pc.id=v.conditionid " +
                            "where" +
                            "  pi.providerid=case when pc.providerid<>0 THEN pc.providerid else case when pi.primaryprovider then pi.providerid else 0 end end" +
                            "  and copayamount<>0" +
                            "  and not copayaspercent" +
                            "  and active" +
                            "  and pi.patientId=" + patientId;
                    ResultSet insRs=io.opnRS(insuranceQuery);
//                    ResultSet insRs=io.opnRS("select * from patientinsurance where primaryprovider and copayamount<>0 and not copayaspercent and patientId=" + this.patientId);
                    if(insRs.next()) {
                        Charge charge=new Charge(io, "0");
                        charge.setId(0);
                        charge.setVisitId(visitId);
                        charge.setItemId(itmRs.getInt("id"));
                        charge.setResourceId(0);
                        charge.setChargeAmount(insRs.getBigDecimal("copayamount"));
                        charge.setCopayAmount(insRs.getBigDecimal("copayamount"));
                        charge.setQuantity(new BigDecimal("1"));
                        charge.update();
                    }
                    insRs.close();
                    insRs=null;
                }
                visitRs.close();
                visitRs=null;
            }
            itmRs.close();
            itmRs=null;
        } catch (Exception e) {
        }
    }
%>

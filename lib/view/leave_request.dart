import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveRequest {
  String name;
  String leaveType;
  DateTime startDate;
  DateTime endDate;
  int daysCount;
  String note;
  String initial;
  String status;

  LeaveRequest({
    required this.name,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.daysCount,
    required this.note,
    required this.initial,
    this.status = 'Pending',
  });
}

class LeaveRequestPage extends StatefulWidget {
  const LeaveRequestPage({super.key});


  @override
  State<LeaveRequestPage> createState() => _LeaveRequestPageState();
}


class _LeaveRequestPageState extends State<LeaveRequestPage> {
  List<LeaveRequest> allLeaveRequests = [];
   bool isloading= true;

@override
 void initState() {

    super.initState();
    fetchdata();

  }
  void fetchdata()async{
       var responce=await FirebaseFirestore.instance.collection('leaverequest').get();
       List data=responce.docs;
        //  print(data);
        
        
        for(int i =0;i<data.length;i++){
         var document=data[i];
         DateFormat format = DateFormat("dd MMM yyyy");

         LeaveRequest leaverequest = LeaveRequest(name: document['name'] , leaveType: document['leaveType'], startDate:format.parse(document['start']) , endDate:format.parse(document['end']), daysCount: 2, note: 'not', initial: 'A');
        allLeaveRequests.add(leaverequest);
        
         print(document['name']);
         print(document['start']);
         print(document['end']);
         print(document['leaveType']);

        }
        print(allLeaveRequests);  
        setState(() {
          isloading=false;
        });   
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Requests'),
      ),
      backgroundColor: const Color.fromARGB(255, 152, 49, 207),
      body: ListView.builder(
        itemCount: allLeaveRequests.length,
        itemBuilder: (context, index) {
          final leave = allLeaveRequests[index];
          return Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            const Color.fromARGB(255, 174, 132, 252),
                        child: Text(
                          leave.initial,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            leave.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Type: ${leave.leaveType}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'From: ${DateFormat('dd MMM yyyy').format(leave.startDate)}',
                      ),

                      Text(
                        'To: ${DateFormat('dd MMM yyyy').format(leave.endDate)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Duration: ${leave.daysCount}'),
                  const SizedBox(height: 8),
                  Text('Reason: ${leave.note}'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _actionButton('View', Colors.blueAccent, () async{
                        await FirebaseFirestore.instance.collection("leaverequest").add({"name":"arati","leaveType":"casual leave"});
                        _showDetailsDialog(context, leave);
                      }),
                      const SizedBox(width: 8),
                      _actionButton('Reject', Colors.redAccent, () async{
                        await FirebaseFirestore.instance.collection("rejectlist").add({"arati":"important deadlines"});
                        setState(() {
                          leave.status = 'Rejected';
                        });
                      }),
                      const SizedBox(width: 8),
                      _actionButton('Approve', Colors.green, () {
                        setState(() {
                          leave.status = 'Approved';
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Status: ${leave.status}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: leave.status == 'Approved'
                            ? Colors.green
                            : leave.status == 'Rejected'
                                ? Colors.red
                                : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  void _showDetailsDialog(BuildContext context, LeaveRequest leave) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${leave.name} - Details'),
        content: Text(
          'Leave Type: ${leave.leaveType}\n'
          'From: ${DateFormat('dd MMM yyyy').format(leave.startDate)}\n'
          'To: ${DateFormat('dd MMM yyyy').format(leave.endDate)}\n'
          'Days: ${leave.daysCount}\n'
          'Reason: ${leave.note}\n'
          'Status: ${leave.status}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

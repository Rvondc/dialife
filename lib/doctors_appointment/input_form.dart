import 'package:dialife/api/api.dart';
import 'package:dialife/api/entities.dart';
import 'package:dialife/doctors_appointment/entities.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class NewDoctorsAppointmentForm extends StatefulWidget {
  final Database _db;

  const NewDoctorsAppointmentForm({
    super.key,
    required Database db,
    required DoctorsAppointmentRecord? existing,
  }) : _db = db;

  @override
  State<NewDoctorsAppointmentForm> createState() =>
      _NewDoctorsAppointmentFormState();
}

class _NewDoctorsAppointmentFormState extends State<NewDoctorsAppointmentForm> {
  List<APIDoctor> _doctors = [];
  List<APIAppointment> _appointments = [];
  APITimeSlotSchedule? _schedule;
  APIDoctor? _selectedDoctor;
  APITimeSlot? _selectedTimeSlot;

  bool _isLoading = true;
  bool _isScheduleLoading = false;

  String? _appointmentReason;
  DateTime? _appointmentDate = DateTime.now();
  TimeOfDay? _appointmentTime;
  int duration = 15; // Either 15, 30, 45, or 60 minutes

  final _appointmentNotes = TextEditingController();

  @override
  void initState() {
    super.initState();

    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    final doctors = await MonitoringAPI.getDoctors();
    final appointments = await MonitoringAPI.getAppointments();

    setState(() {
      _doctors = doctors;
      _appointments = appointments;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Appointments"),
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _content(),
        ),
      ),
    );
  }

  Widget _content() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/appointments.png',
                height: 100,
              ),
              const SizedBox(height: 24),
              Text(
                'Existing Appointments',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = _appointments[index];
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Card(
                        color: Colors.white,
                        elevation: 4,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    appointment.doctor.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: appointment.status ==
                                              "Pending".toLowerCase()
                                          ? Colors.orange[100]
                                          : appointment.status ==
                                                  "Confirmed".toLowerCase()
                                              ? Colors.green[100]
                                              : appointment.status ==
                                                      "Completed".toLowerCase()
                                                  ? Colors.blue[100]
                                                  : appointment.status ==
                                                          "Canceled"
                                                              .toLowerCase()
                                                      ? Colors.red[100]
                                                      : appointment.status ==
                                                              "Rescheduled"
                                                                  .toLowerCase()
                                                          ? Colors.purple[100]
                                                          : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      appointment.status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: appointment.status == "Pending"
                                            ? Colors.orange[800]
                                            : appointment.status == "Confirmed"
                                                ? Colors.green[800]
                                                : appointment.status ==
                                                        "Completed"
                                                    ? Colors.blue[800]
                                                    : appointment.status ==
                                                            "Canceled"
                                                        ? Colors.red[800]
                                                        : appointment.status ==
                                                                "Rescheduled"
                                                            ? Colors.purple[800]
                                                            : Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${appointment.appointmentDate.toLocal().toString().split(' ')[0]} ${TimeOfDay(hour: int.parse(appointment.appointmentTime.split(':')[0]), minute: int.parse(appointment.appointmentTime.split(':')[1])).format(context)}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${appointment.durationMinutes} minutes - ${appointment.reason}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Doctor',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<APIDoctor>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: _doctors
                    .map((doctor) => DropdownMenuItem(
                          value: doctor,
                          child: Text(doctor.name),
                        ))
                    .toList(),
                onChanged: (doctor) async {
                  setState(() {
                    _isScheduleLoading = true;
                  });
                  final now = _appointmentDate ?? DateTime.now();
                  final sched =
                      await MonitoringAPI.getTimeSlots(doctor!.id, now);

                  setState(() {
                    _schedule = sched;
                    _isScheduleLoading = false;
                    _selectedDoctor = doctor;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Duration',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          value: duration,
                          items: [15, 30, 45, 60]
                              .map((d) => DropdownMenuItem(
                                    value: d,
                                    child: Text("$d minutes"),
                                  ))
                              .toList(),
                          onChanged: (newDuration) {
                            if (newDuration == null) return;

                            setState(() {
                              duration = newDuration;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Appointment Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );

                            if (pickedDate == null) return;

                            setState(() {
                              _appointmentDate = pickedDate;
                            });

                            if (_selectedDoctor == null) return;

                            setState(() {
                              _isScheduleLoading = true;
                            });

                            final sched = await MonitoringAPI.getTimeSlots(
                              _selectedDoctor!.id,
                              pickedDate,
                            );

                            setState(() {
                              _schedule = sched;
                              _isScheduleLoading = false;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _appointmentDate == null
                                      ? 'Select Date'
                                      : "${_appointmentDate!.toLocal()}"
                                          .split(' ')[0],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey.shade700,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Time Slots',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              if (_schedule != null)
                SizedBox(
                  height: 100,
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 0.33,
                    scrollDirection: Axis.horizontal,
                    children: () {
                      List<APITimeSlot> slots = [];

                      switch (duration) {
                        case 15:
                          slots = _schedule!.fifteen;
                          break;
                        case 30:
                          slots = _schedule!.thirty;
                          break;
                        case 45:
                          slots = _schedule!.fortyFive;
                          break;
                        case 60:
                          slots = _schedule!.sixty;
                          break;
                      }

                      return slots
                          .map((time) => GestureDetector(
                                onTap: () {
                                  if (_selectedTimeSlot == time) {
                                    setState(() {
                                      _selectedTimeSlot = null;
                                    });

                                    return;
                                  }

                                  setState(() {
                                    _selectedTimeSlot = time;
                                    final parts = time.start.split(":");

                                    _appointmentTime = TimeOfDay(
                                      hour: int.parse(parts[0]),
                                      minute: int.parse(parts[1]),
                                    );
                                  });
                                },
                                child: Card(
                                  elevation: 2,
                                  color: _selectedTimeSlot == time
                                      ? Colors.blue[100]
                                      : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        "${time.start} - ${time.end}",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ),
                              ))
                          .toList();
                    }(),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Reason',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Checkup',
                    child: Text("Checkup"),
                  ),
                  DropdownMenuItem(
                    value: 'Follow-up',
                    child: Text("Follow-up"),
                  ),
                  DropdownMenuItem(
                    value: 'Consultation',
                    child: Text("Consultation"),
                  ),
                  DropdownMenuItem(
                    value: 'Procedure',
                    child: Text("Procedure"),
                  ),
                  DropdownMenuItem(
                    value: 'Emergency',
                    child: Text("Emergency"),
                  ),
                ],
                onChanged: (reason) {
                  _appointmentReason = reason;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: "Enter notes here",
                  alignLabelWithHint: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: 5,
                textAlignVertical: TextAlignVertical.top,
                controller: _appointmentNotes,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () async {
                  if (_selectedDoctor == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select a doctor"),
                      ),
                    );

                    return;
                  }

                  if (_selectedTimeSlot == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select a time slot"),
                      ),
                    );

                    return;
                  }

                  if (_appointmentReason == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("Please select a reason for the appointment"),
                      ),
                    );

                    return;
                  }

                  if (_appointmentDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select a date"),
                      ),
                    );

                    return;
                  }

                  setState(() {
                    _isScheduleLoading = true;
                  });

                  await MonitoringAPI.createAppointment(
                    doctorId: _selectedDoctor!.id,
                    date: _appointmentDate!,
                    time: _appointmentTime!,
                    duration: Duration(minutes: duration),
                    reason: _appointmentReason!,
                  );

                  final slots = await MonitoringAPI.getTimeSlots(
                    _selectedDoctor!.id,
                    _appointmentDate!,
                  );

                  setState(() {
                    _schedule = slots;
                    _isScheduleLoading = false;
                    _appointmentReason = null;
                    _selectedDoctor = null;
                    _appointmentNotes.clear();
                  });

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Appointment Created!"),
                    ),
                  );
                },
                child: const Text("Submit"),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        if (_isScheduleLoading)
          const AlertDialog(
            backgroundColor: Colors.white,
            elevation: 5,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                SizedBox(height: 16),
                Text("Loading Available Time Slots..."),
              ],
            ),
          ),
      ],
    );
  }
}

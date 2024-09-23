// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class MyAppointmentCard extends StatelessWidget {
  final String docProfilePic;
  final String docName;
  final String docCategory;
  final String rating;
  final String date;
  final String time;
  final VoidCallback onTap;

  const MyAppointmentCard({
    Key? key,
    required this.docName,
    required this.docCategory,
    required this.rating,
    required this.date,
    required this.time,
    required this.docProfilePic, required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateFormat('MM/dd/yyyy').parse(date);

    String dayOfWeek = DateFormat('EEEE').format(dateTime);
    String day = DateFormat('d').format(dateTime);
    String month = DateFormat('MMM').format(dateTime);

    if (DateUtils.isSameDay(DateTime.now(), dateTime)) {
      dayOfWeek = "Today";
    }

    bool isEven = int.parse(day) % 2 == 0;

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            height: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          // color: Color(0xFF40B44F),
                          color: isEven
                              ? const Color(0xFF40B44F)
                              : const Color(0xFF109421),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isEven
                              ? const Color(0xFF109421)
                              : const Color(0xFF40B44F),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dayOfWeek,
                        style: GoogleFonts.nunitoSans(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Iconsax.record,
                              color: Colors.white,
                              size: 10,
                            ),
                            Text(
                              day,
                              style: GoogleFonts.montserratAlternates(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 50,
                              ),
                            ),
                            const Icon(
                              Iconsax.record,
                              color: Colors.white,
                              size: 10,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        month,
                        style: GoogleFonts.nunitoSans(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 5,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 190,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    width: 1, color: const Color(0xFF8391A1).withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(docProfilePic),
                          radius: 28,
                        ),
                        const Spacer(),
                        Container(
                          width: 75,
                          height: 30,
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(2)),
                          child: Center(
                            child: Text(
                              time,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunitoSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      docName,
                      style: GoogleFonts.nunitoSans(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      docCategory,
                      style: GoogleFonts.nunitoSans(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 18,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          rating,
                          style: GoogleFonts.nunitoSans(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Iconsax.more),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 30,
        ),
      ],
    );
  }
}

import 'package:docdial/doctor/model/doctor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorDetailCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  // ignore: use_super_parameters
  const DoctorDetailCard({
    Key? key,
    required this.onTap,
    required this.doctor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: NetworkImage(doctor.profileImageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Dr. ${doctor.firstName} ${doctor.lastName}",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunitoSans(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        RatingStars(
                          axis: Axis.horizontal,
                          value: doctor.averageRating,
                          starCount: 5,
                          starSize: 13,
                          maxValue: 5,
                          starSpacing: 2,
                          maxValueVisibility: false,
                          valueLabelVisibility: false,
                          animationDuration: const Duration(milliseconds: 1000),
                          valueLabelPadding: const EdgeInsets.symmetric(
                              vertical: 1, horizontal: 8),
                          valueLabelMargin: const EdgeInsets.only(right: 8),
                          starOffColor: const Color(0xffe7e8ea),
                          starColor: Colors.amber,
                          angle: 0,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Category",
                            style: GoogleFonts.nunitoSans(
                              color: Colors.black.withOpacity(0.3),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            doctor.category,
                            style: GoogleFonts.nunitoSans(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Experience",
                            style: GoogleFonts.nunitoSans(
                              color: Colors.black.withOpacity(0.3),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "${doctor.yearsOfExperience} Years",
                            style: GoogleFonts.nunitoSans(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "City",
                            style: GoogleFonts.nunitoSans(
                              color: Colors.black.withOpacity(0.3),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            doctor.city,
                            style: GoogleFonts.nunitoSans(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: 40,
        width: 1.0,
        color: Colors.black.withOpacity(0.2),
        margin: const EdgeInsets.only(top: 2),
      ),
    );
  }
}
// import 'package:docdial/doctor/model/doctor.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_rating_stars/flutter_rating_stars.dart';
// import 'package:google_fonts/google_fonts.dart';

// class DoctorDetailCard extends StatelessWidget {
//   final Doctor doctor;
//   final VoidCallback onTap;

//   // ignore: use_super_parameters
//   const DoctorDetailCard({
//     Key? key,
//     required this.onTap,
//     required this.doctor,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 30, bottom: 10),
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//             color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
//         child: Padding(
//           padding: const EdgeInsets.all(15),
//           child: Column(
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     width: 50,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       color: Colors.amber,
//                       borderRadius: BorderRadius.circular(15),
//                       image: DecorationImage(
//                         image: NetworkImage(doctor.profileImageUrl),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Dr. ${doctor.firstName} ${doctor.lastName}",
//                         textAlign: TextAlign.center,
//                         style: GoogleFonts.nunitoSans(
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 5),
//                       RatingStars(
//                         axis: Axis.horizontal,
//                         value: 2,
//                         onValueChanged: (v) {},
//                         starCount: 5,
//                         starSize: 13,
//                         maxValue: 5,
//                         starSpacing: 2,
//                         maxValueVisibility: false,
//                         valueLabelVisibility: false,
//                         animationDuration: const Duration(milliseconds: 1000),
//                         valueLabelPadding: const EdgeInsets.symmetric(
//                             vertical: 1, horizontal: 8),
//                         valueLabelMargin: const EdgeInsets.only(right: 8),
//                         starOffColor: const Color(0xffe7e8ea),
//                         starColor: Colors.amber,
//                         angle: 0,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Category",
//                           style: GoogleFonts.nunitoSans(
//                             color: Colors.black.withOpacity(0.3),
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                           ),
//                         ),
//                         Text(
//                           doctor.category,
//                           style: GoogleFonts.nunitoSans(
//                             color: Colors.black,
//                             fontWeight: FontWeight.w700,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   _buildDivider(),
//                   Expanded(
//                     flex: 2,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Experience",
//                           style: GoogleFonts.nunitoSans(
//                             color: Colors.black.withOpacity(0.3),
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                           ),
//                         ),
//                         Text(
//                           "${doctor.yearsOfExperience} Years",
//                           style: GoogleFonts.nunitoSans(
//                             color: Colors.black,
//                             fontWeight: FontWeight.w700,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   _buildDivider(),
//                   Expanded(
//                     flex: 2,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "City",
//                           style: GoogleFonts.nunitoSans(
//                             color: Colors.black.withOpacity(0.3),
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                           ),
//                         ),
//                         Text(
//                           doctor.city,
//                           style: GoogleFonts.nunitoSans(
//                             color: Colors.black,
//                             fontWeight: FontWeight.w700,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDivider() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       child: Container(
//         height: 40,
//         width: 1.0,
//         color: Colors.black.withOpacity(0.2),
//         margin: const EdgeInsets.only(top: 2),
//       ),
//     );
//   }
// }

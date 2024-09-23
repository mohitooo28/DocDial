import 'package:docdial/doctor/model/doctor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopDoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  // ignore: use_super_parameters
  const TopDoctorCard({
    Key? key,
    required this.onTap,
    required this.doctor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xFFEDEFFF)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(doctor.profileImageUrl),
                            fit: BoxFit.cover,
                          )),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Dr. ${doctor.firstName} ${doctor.lastName}",
                      style: GoogleFonts.nunitoSans(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      doctor.category,
                      style: GoogleFonts.nunitoSans(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        //!******
        Positioned(
          top: 15,
          right: 16,
          child: Container(
            width: 55,
            height: 30,
            decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5))),
            child: Center(
              child: Text(
                "☆ ${doctor.averageRating}",
                style: GoogleFonts.nunitoSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        )
        //!******
      ],
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class TopDoctorCard extends StatelessWidget {
//   final String? profilePic;
//   final String docName;
//   final String rating;
//   final String docCategory;
//   final VoidCallback onTap;

//   // ignore: use_super_parameters
//   const TopDoctorCard({
//     Key? key,
//     required this.onTap,
//     required this.profilePic,
//     required this.docName,
//     required this.docCategory,
//     required this.rating,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(right: 15),
//           child: GestureDetector(
//             onTap: onTap,
//             child: Container(
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(18),
//                   color: const Color(0xFFEDEFFF)),
//               child: Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       width: 150,
//                       height: 150,
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           image: DecorationImage(
//                             image: NetworkImage(profilePic ?? ""),
//                             fit: BoxFit.cover,
//                           )),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       "Dr. $docName",
//                       style: GoogleFonts.nunitoSans(
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                     ),
//                     Text(
//                       docCategory,
//                       style: GoogleFonts.nunitoSans(
//                         color: Colors.black,
//                         fontWeight: FontWeight.w400,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//         //!******
//         Positioned(
//           top: 15,
//           right: 16,
//           child: Container(
//             width: 55,
//             height: 30,
//             decoration: const BoxDecoration(
//                 color: Colors.green,
//                 borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(5),
//                     bottomLeft: Radius.circular(5))),
//             child: Center(
//               child: Text(
//                 "☆ $rating",
//                 style: GoogleFonts.nunitoSans(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 15,
//                 ),
//               ),
//             ),
//           ),
//         )
//         //!******
//       ],
//     );
//   }
// }

import 'package:docdial/doctor/doctor_details_page.dart';
import 'package:docdial/doctor/model/doctor.dart';
import 'package:docdial/patient/widget/doctor_card.dart';
import 'package:docdial/patient/widget/loadingbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:svg_flutter/svg.dart';

class SearchResultPage extends StatefulWidget {
  final String searchQuery;

  const SearchResultPage({super.key, required this.searchQuery});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Doctor> _searchResults = [];
  bool _isLoading = false;
  bool _noResultsFound = false;

  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the search query value
    _searchController = TextEditingController(text: widget.searchQuery);

    // Trigger search when the page loads
    if (widget.searchQuery.isNotEmpty) {
      _searchDoctorsByName(widget.searchQuery);
    }
  }

  Future<void> _searchDoctorsByName(String searchQuery) async {
    setState(() {
      _isLoading = true;
      _noResultsFound = false;
    });

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Doctors')
          .where('firstName', isGreaterThanOrEqualTo: searchQuery)
          .where('firstName', isLessThanOrEqualTo: '$searchQuery\uf8ff')
          .get();

      List<Doctor> tmpResults = snapshot.docs.map((doc) {
        return Doctor.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      setState(() {
        _searchResults = tmpResults;
        _isLoading = false;
        _noResultsFound = _searchResults.isEmpty;
      });
    } catch (e) {
      print("Error searching doctors: $e");
      setState(() {
        _isLoading = false;
        _noResultsFound = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar ---------------------------------------------------
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF40B44F), Color(0xFF109421)],
                    begin: FractionalOffset(0.0, 0.0),
                    end: FractionalOffset(1.0, 0.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                "Search",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunitoSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 30, bottom: 30),
                        child: TextFormField(
                          controller: _searchController, // Set the controller
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left: 20, top: 15, bottom: 15),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            hintText: 'Search doctor',
                            hintStyle: GoogleFonts.lato(
                              color: Colors.black26,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF8391A1),
                            ),
                          ),
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                          onFieldSubmitted: (String value) {
                            // Re-trigger search with the new input
                            if (value.isNotEmpty) {
                              _searchDoctorsByName(value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Results Section ----------------------------------------------
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Text(
                      "Search Results",
                      style: GoogleFonts.nunitoSans(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
              _isLoading
                  ? const CustomCircularLoading()
                  : _noResultsFound
                      ? Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 50),
                              SvgPicture.asset(
                                "assets/vector/nothing.svg",
                                height: 250,
                              ),
                              const SizedBox(height: 30),
                              Text(
                                'No doctors available with that name.',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            children: List.generate(
                              _searchResults.length,
                              (index) => DoctorDetailCard(
                                doctor: _searchResults[index],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DoctorDetailPage(
                                        doctor: _searchResults[index],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

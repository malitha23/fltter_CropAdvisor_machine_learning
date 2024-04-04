import 'package:agriculture/screens/diseaseDetailPage.dart';
import 'package:agriculture/screens/fullScreenImage.dart';
import 'package:agriculture/screens/getCropsWithSimilarSoilType.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SelectedCropPage extends StatefulWidget {
  final Crop crop;

  const SelectedCropPage({Key? key, required this.crop}) : super(key: key);

  @override
  State<SelectedCropPage> createState() => _SelectedCropPageState();
}

class _SelectedCropPageState extends State<SelectedCropPage> {
  Uint8List defaultImageBytes = Uint8List(0);

  void _setDefaultImage() async {
    final ByteData data = await rootBundle.load('assets/images/noimage.jpg');
    setState(() {
      defaultImageBytes = data.buffer.asUint8List();
    });
  }

  @override
  void initState() {
    super.initState();
    _setDefaultImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Color.fromRGBO(5, 183, 119, 1), // Set background color to white
        foregroundColor: Colors.white,
        title: Text(
          widget.crop.cropName,
          style: const TextStyle(
            color: Colors.white, // Set text color to black
            fontSize: 16, // Set font size to 16
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display main image if available, otherwise display default image
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImage(
                        imageBytes: widget.crop.decodedMainImage!),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 227, 225, 225)
                          .withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: widget.crop.decodedMainImage != null &&
                          widget.crop.decodedMainImage!.isNotEmpty
                      ? Image.memory(
                          widget.crop.decodedMainImage!,
                          fit: BoxFit.fitWidth,
                        )
                      : Image.memory(
                          defaultImageBytes,
                          fit: BoxFit.fitWidth,
                        ),
                ),
              ),
            ),

            const SizedBox(height: 10.0),
            SizedBox(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final subImage in widget.crop.decodedSubImages)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FullScreenImage(imageBytes: subImage!),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color.fromARGB(255, 227, 225, 225)
                                          .withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 3,
                                  offset: Offset(
                                      0, 1), // changes position of shadow
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: subImage != null
                                  ? Image.memory(
                                      subImage,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey, // Placeholder color
                                    ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Crop Name: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${widget.crop.cropName}'),
              ],
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Zone: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${widget.crop.zone}'),
              ],
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Soil Type: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${widget.crop.soilType}'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Season: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${widget.crop.selectedSeason}'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Watering Cycle: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${widget.crop.selectedWateringCycle}'),
              ],
            ),
            const SizedBox(height: 12),

            if (widget.crop.weeklyOption != null)
              Row(
                children: [
                  Text(
                    'Weekly Option: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${widget.crop.weeklyOption}'),
                ],
              ),
            if (widget.crop.weeklyOption != null) const SizedBox(height: 12),
            if (widget.crop.timeOption != null)
              Row(
                children: [
                  Text(
                    'Time Option: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${widget.crop.timeOption}'),
                ],
              ),
            if (widget.crop.timeOption != null) const SizedBox(height: 12),
            if (widget.crop.dailyOption != '')
              Row(
                children: [
                  Text(
                    'Daily Option: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${widget.crop.dailyOption}'),
                ],
              ),
            if (widget.crop.dailyOption != '') const SizedBox(height: 12),
            Text(
              'Disease:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8.0, // Adjust the spacing between labels as needed
              children: widget.crop.selectedDiseaseList.map((disease) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiseaseDetailPage(
                            diseaseiD: disease.split(
                                ": ")[0]), // Pass your disease value here
                      ),
                    );
                  },
                  child: Chip(
                    label: Text(disease.split(": ")[1]),
                    backgroundColor: Colors.blueGrey, // Adjust color as needed
                    labelStyle: TextStyle(
                        color:
                            Colors.white), // Adjust label text color as needed
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Crop Variety: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${widget.crop.cropVariety}'),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              'Life Cycle Description: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10.0), // Add padding around the text
              color: Colors.grey[200], // Set gray color background
              child: Text(
                '${widget.crop.lifeCycleDescription}',
                softWrap: true,
              ),
            ),

            const SizedBox(height: 10.0),
            SizedBox(
              height: 55,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final subImage
                        in widget.crop.decodedlifeCycleImagePaths)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FullScreenImage(imageBytes: subImage!),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color.fromARGB(255, 227, 225, 225)
                                          .withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 3,
                                  offset: Offset(
                                      0, 1), // changes position of shadow
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: subImage != null
                                  ? Image.memory(
                                      subImage,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey, // Placeholder color
                                    ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

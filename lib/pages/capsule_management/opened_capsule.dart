import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:retro/components/colors.dart';

class OpenedCapsule extends StatefulWidget {
  const OpenedCapsule({Key? key}) : super(key: key);

  @override
  State<OpenedCapsule> createState() => _OpenedCapsuleState();
}

class _OpenedCapsuleState extends State<OpenedCapsule> {
  PageController _pageController = PageController();
  int _currentPageIndex = 0;
 

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _previousImage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
    _pageController.jumpToPage(9); // Jump to the first page (index 0)
  }
  }

  void _nextImage() {
    if (_currentPageIndex < 9) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
    _pageController.jumpToPage(0); 
  }
  }

  Widget _buildCircleIndicator(int index) {
    return Container(
      width: 5,
      height: 5,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index == _currentPageIndex % 5
            ? AppColors.primaryColor
            : AppColors.secondaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        leading: ModalRoute.of(context)?.canPop == true
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  "Summer Trip Memo",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _previousImage,
                        icon: const Icon(Icons.chevron_left,
                        color: AppColors.primaryColor,
                        size: 40,),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 240,
                          height: 320,
                          color: Colors
                              .grey, // Placeholder color for the rectangle
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: 10,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              // You can replace this with your image widget
                              return Image.asset(
                                'image/test${index + 1}.JPG',
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _nextImage,
                        icon: const Icon(Icons.chevron_right,
                        color: AppColors.primaryColor,
                        size: 40,),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => _buildCircleIndicator(index),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.backgroundColor,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                            "In non neque congue, tincidunt lacus nec, "
                            "sollicitudin lectus. Vestibulum rhoncus metus egestas metus "
                            "consectetur suscipit. Praesent malesuada ipsum vel magna "
                            "accumsan molestie. Pellentesque pharetra dignissim nulla, "
                            "vel tincidunt justo. Donec metus eros, cursus nec massa eu, "
                            "faucibus dignissim ipsum. Nunc placerat fringilla lorem, "
                            "nec lobortis metus scelerisque fringilla. Vestibulum lorem magna, c"
                            "onvallis nec dignissim sit amet, malesuada ac nibh. Phasellus "
                            "ullamcorper sagittis ipsum, eu vehicula turpis tristique a. "
                            "Mauris eget ornare est. Duis finibus, diam non vestibulum luctus, "
                            "mauris dui sodales urna, et ornare odio velit eget augue. Vivamus"
                            " eget blandit erat."
                            "Maecenas justo ex, vestibulum id lacus a, elementum posuere leo. "
                            "In hac habitasse platea dictumst. Nullam a libero felis. Donec vel nunc metus. "
                            "Sed id mi et tortor vestibulum eleifend. Sed a ultricies quam. "
                            "Curabitur egestas ligula nulla, sit amet posuere elit gravida in.",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textColor,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: SizedBox(
                        width: 160,
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryColor, width: 1.0),
                          ),
                          onPressed: (){
                             Navigator.pop(context);
                          },
                          child: const Text(
                            'Done',
                            style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize:16.0),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

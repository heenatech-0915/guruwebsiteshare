import 'dart:io';
// import 'package:flowder/flowder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:whatsapp_share2/whatsapp_share2.dart';
import '../../../utils/app_theme_data.dart';

class BrochurePdfPage extends StatefulWidget {
   BrochurePdfPage({
     Key? key,
     this.pdfUrl="",this.brochuresPage=false,
     this.title=""
   }) : super(key: key);

  String ?pdfUrl;
  bool brochuresPage = false;
  String title;

  @override
  State<BrochurePdfPage> createState() => _BrochurePdfPageState();
}

class _BrochurePdfPageState extends State<BrochurePdfPage> {
  final String url = "https://cpcdiagnostics.bizzonit.com/public/";

  bool isLoading  = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        centerTitle: true,
        title: Text(
           widget.title,
          style: AppThemeData.headerTextStyle_16,
        ),
        actions: [
          InkWell(
            onTap: share,
            child: Padding(
              padding: EdgeInsets.only(right: 20.w),
              child: const Icon(Icons.share,color: Colors.green,),
            ),
          ),
          InkWell(
            onTap: (){downloadBrochure(url);},
            child: Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: Icon(Icons.download,color: AppThemeData.primaryColor,),
            ),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [

          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: SfPdfViewer.network(
                widget.brochuresPage ?widget.pdfUrl!:url+widget.pdfUrl!,
                onDocumentLoaded: (v){
                  setState(() {
                    isLoading = false;
                  });
                },
            ),
          ),

          isLoading
                  ? const Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator())
                  : const SizedBox(),

          downloadProgress!=0.0?ShowUpAnimation(
            offset: 1,
            direction: Direction.vertical,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 100.h,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              padding: EdgeInsets.all(20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Text("Downloading")
                ],
              ),
            ),
          ):const SizedBox()
        ],
      ),
    );
  }

  Future<void> share() async {
    var result = await FlutterShareMe().shareToWhatsApp4Biz(msg: url+widget.pdfUrl!);
      /*await WhatsappShare.share(
        text: 'Whatsapp share text',
        linkUrl: url+widget.pdfUrl!,
        phone: '1',
      );*/
    }

  String path = "";
  double downloadProgress = 0.0;
  bool isDownloading = false;

  downloadBrochure(String pdf) async {
    isDownloading = true;
    try {
      Directory _path = await getApplicationDocumentsDirectory();
      String _localPath = '${_path.path}${Platform.pathSeparator}Download';
      final savedDir = Directory(_localPath);
      bool hasExisted = await savedDir.exists();
      if (!hasExisted) {
        savedDir.create();
      }
      path = _localPath;
      // DownloaderCore core;
      // DownloaderUtils options;
      // options = DownloaderUtils(
      //   progressCallback: (current, total) {
      //     final progress = (current / total) * 100;
      //     downloadProgress = progress;
      //   },
      //   file: File('$path/$pdf.pdf'),
      //   progress: ProgressImplementation(),
      //   onDone: () {
      //     OpenFile.open('$path/$pdf.pdf');
      //   },
      //   deleteOnCancel: true,
      // );
      // core = await Flowder.download(
      //   widget.brochuresPage
      //       ? widget.pdfUrl!
      //       : url + widget.pdfUrl!,
      //   options,
      // );
    }
  catch(e){
    isDownloading = false;
    if (kDebugMode) {
      print(e);
    }
    }
  }

}

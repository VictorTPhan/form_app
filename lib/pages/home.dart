import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:collapsible/collapsible.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:flutter/material.dart';
import 'package:form_app/pages/create_form.dart';
import 'package:form_app/misc.dart';
import 'package:form_app/pages/response.dart';
import 'package:form_app/pages/view_form.dart';
import 'package:get_storage/get_storage.dart';
import '../forms/generated_form.dart';
import '../forms/generated_response.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  /// A [Map] representing a:
  ///
  /// Map of JSON -> List<String>
  ///
  /// which can be alternatively thought of as:
  ///
  /// Form JSON -> Response UUIDs
  Map<Map<String, dynamic>, List<String>> displayForms = {};

  /// A [Map] used to keep track of which form response [ListView]s are being shown
  Map<Map<String, dynamic>, bool> responseListViewStatuses = {};

  /// A reference to the [GetStorage] filesystem.
  late final GetStorage box;

  /// The amount of extra time it takes for a question on this page to load,
  /// in milliseconds.
  int delayIncrease = 200;

  /// The amount of time it takes for a question on this page to load, in
  /// milliseconds. Every newly loaded question widget increases this value.
  late int delay = -delayIncrease;




  @override
  initState() {
    box = GetStorage();
    fetchSavedData();
  }

  /// Reads from the [BoxStorage] file system and loads all of the read data into
  /// [displayForms] and [responseListViewStatuses].
  void fetchSavedData() {
    // Clear out any currently displayed data.
    displayForms.clear();
    responseListViewStatuses.clear();

    // Read from the SAVED_FORMS list, which contains the UUIDs of all saved forms.
    List<dynamic> savedForms = box.read("SAVED_FORMS") ?? [];

    // Create a list of unreachable UUIDs that may or may not be populated afterwards.
    List<String> unreachableUUIDs = [];

    for (String formUUID in savedForms) {
      // Attempt to read from the box.
      var searchResult = box.read(formUUID);

      // If nothing comes up, this UUID is a dud and we can throw it away.
      if (searchResult == null) {
        unreachableUUIDs.add(formUUID);
        continue;
      } else {
        // Create a list of response UUID strings related to this form.
        displayForms[searchResult] = [];

        // Mark this form's response ListView as collapsed.
        responseListViewStatuses[searchResult] = false;

        // Attempt to read from the list of response UUIDs. If nothing
        // comes up, this is an empty list.
        List<dynamic> responses = box.read("$formUUID/responses") ?? [];
        for (String responseUUID in responses) {
          // Attempt to read this response UUID.
          var responseExists = box.read(responseUUID);

          // This is a valid response UUID and we can display it.
          if (responseExists != null){
            displayForms[searchResult]!.add(responseUUID);
          } else {
            // If nothing comes up, this UUID is a dud and we can throw it away.
            unreachableUUIDs.add(responseUUID);
          }
        }
      }
    }
  }

  /// Refreshes the feed with updated data from the [GetStorage] box.
  Future<void> fetchSavedDataSetState() async {
    setState(() {
      fetchSavedData();
    });
  }

  /// Displays a widget representing a link to view a generated [response].
  Widget displayResponseBar(GeneratedResponse response, String responseUUID) {
    return GestureDetector(
      onTap: () {
        navigateTo(context, ResponsePage(responseUUID: responseUUID));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimatedTextKit(
            isRepeatingAnimation: false,
            animatedTexts: [
              TypewriterAnimatedText(
                  speed: const Duration(milliseconds: 50),
                  textStyle: standardTextStyle(),
                  "${response.emoji}  ${response.name}"
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Displays a [ListView] under a form bar widget displaying all of its
  /// associated responses [responseUUIDs].
  Widget displayResponseListView(bool responseListViewIsCollapsed, List<String> responseUUIDs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.90,
          child: Collapsible(
            collapsed: responseListViewIsCollapsed,
            fade: true,
            curve: Curves.easeInOut,
            axis: CollapsibleAxis.vertical,
            child: FadeInDown(
              from: 10,
              duration: const Duration(milliseconds: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: responseUUIDs.length,
                itemBuilder: (BuildContext context, int rIndex) {
                  final GeneratedResponse response = GeneratedResponse.fromJson(box.read(responseUUIDs[rIndex]));
                  return displayResponseBar(response, responseUUIDs[rIndex]);
                }
              )
            ),
          ),
        ),
      ),
    );
  }

  /// Deletes a form from the [GetStorage] file system, as well as all associated
  /// generated responses.
  void deleteForm(GeneratedForm generatedForm, List<String> responseUUIDs) {
    // Remove this form
    box.remove(generatedForm.uuid);

    // Remove this form from saved_forms
    List<dynamic> savedForms = box.read("SAVED_FORMS") ?? [];
    savedForms.remove(generatedForm.uuid);
    box.write("SAVED_FORMS", savedForms);

    // Remove all responses related to this form
    for (String responseUUID in responseUUIDs) {
      box.remove(responseUUID);
    }

    // Remove the list of responses
    box.remove("${generatedForm.uuid}/responses");

    // Refresh the data
    fetchSavedDataSetState();
  }

  /// Displays a dialog asking the user if they would like to delete a form.
  void displayFormDeletionDialog(GeneratedForm generatedForm, List<String> responseUUIDs) {
    showDialog(
      context: context,
      builder: (context) => FluidDialog(
        // Set the first page of the dialog.
        rootPage: FluidDialogPage(
          alignment: Alignment.center, //Aligns the dialog to the bottom left.
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeIn(
                  child: Text(
                      style: standardTextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      "Form Deletion"
                  ),
                ),
                FadeIn(
                  child: Text(
                      textAlign: TextAlign.center,
                      style: standardTextStyle(),
                      "Do you want to delete ${generatedForm.emoji} ${generatedForm.name}? This will also delete all associated with it."
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          deleteForm(generatedForm, responseUUIDs);
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green
                        ),
                        child: Text(
                          style: standardTextStyle(
                            color: Colors.white
                          ),
                          "Go ahead"
                        )
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent
                        ),
                        child: Text(
                            style: standardTextStyle(
                                color: Colors.white
                            ),
                            "Nevermind"
                        )
                    ),
                  ],
                ),
              ],
            ),
          ), // This can be any widget.
        ),
      ),
    );
  }

  /// Displays a widget representing and linking to a [GeneratedForm].
  Widget displayFormBar(Map<String, dynamic> formJson, GeneratedForm generatedForm, List<String> responseUUIDs) {
    return GestureDetector(
      onTap: () {
        navigateTo(context, ViewForm(generatedForm: generatedForm));
      },
      onLongPress: () {
        displayFormDeletionDialog(generatedForm, responseUUIDs);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: gradients[generatedForm.colorIndex],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                      style: standardTextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ).copyWith(
                          overflow: TextOverflow.ellipsis
                      ),
                      "${generatedForm.emoji}  ${generatedForm.name}"
                  ),
                ),
                if (responseUUIDs.isNotEmpty)
                  IconButton(
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          responseListViewStatuses[formJson] = !responseListViewStatuses[formJson]!;
                        });
                      },
                      icon: !responseListViewStatuses[formJson]!?
                      const Icon(Icons.expand_more) :
                      const Icon(Icons.expand_less)
                  )
                else
                  SizedBox.fromSize(size: const Size(50, 50))
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Creates a widget that is either a [ListView] containing all generated forms
  /// or a message telling the user to start creating forms.
  Widget getMainBody() {
    if (displayForms.isNotEmpty) {
      return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          itemCount: displayForms.keys.length,
          itemBuilder: (BuildContext context, int fIndex) {
            Map<String, dynamic> formJson = displayForms.keys.elementAt(fIndex);
            GeneratedForm generatedForm = GeneratedForm.fromJson(formJson);
            List<String> responseUUIDs = displayForms[formJson]!;

            delay += delayIncrease;

            return FadeInLeft(
              delay: Duration(milliseconds: delay),
              child: Column(
                children: [
                  displayFormBar(formJson, generatedForm, responseUUIDs),
                  displayResponseListView(!responseListViewStatuses[formJson]!, responseUUIDs)
                ],
              ),
            );
          }
      );
    } else {
      return ListView(
        children: [
          FadeIn(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                style: standardTextStyle(),
                "You don't have any forms made right now. Try making one below."
              ),
            ),
          )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: FadeInDown(
          child: Text(
            style: standardTextStyle(fontSize: 25),
            "Welcome Back!"
          ),
        ),
      ),
      body: EasyRefresh(
        onRefresh: fetchSavedDataSetState,
        child: getMainBody()
      ),
      floatingActionButton: FadeInUp(
        child: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            navigateTo(context, const CreateForm());
          },
        ),
      ),
    );
  }
}

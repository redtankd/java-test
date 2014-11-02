package javafx

import javafx.application.Application
import javafx.fxml.FXMLLoader
import javafx.scene.Scene
import javafx.stage.Stage

class Test extends Application
{
	override void start(Stage primaryStage)
	throws Exception
	{
		val loader = new FXMLLoader(getClass().getResource("sample.fxml"));
		val root = loader.load() 
		val controller = loader.controller as SampleController
		controller.init()
		
		primaryStage.title = "Hello World"
		primaryStage.scene = new Scene(root, 600, 400);
		primaryStage.show();
	}

	def static void main(String[] args)
	{
		launch(args);
	}

}

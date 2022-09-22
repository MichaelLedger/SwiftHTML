var gitbook = window.gitbook;

gitbook.events.on('page.change', function() {
	
	var custom_button = ['<div class="custom-btn">答题模式</div>'].join("");
	$(".book").append(custom_button)

	// $(".custom-btn").hide();

	$('.custom-btn').fadeIn();

	// $('.book-body,.body-inner').on('scroll', function () {
	// 	if ($(this).scrollTop() > 100) { 
	// 		$('.custom-btn').fadeIn();
	// 	} else {
	// 		$('.custom-btn').fadeOut();
	// 	}
	// });

	$('.custom-btn').click(function () { 
		// $('.book-body,.body-inner').animate({
		// 	scrollTop: 0
		// }, 800);
		var selected = $('.custom-btn').prop('selected');
		this.innerHTML = !selected ? "学习模式" : "答题模式";
		// console.log("before" + selected);
		var arrayOfDocFonts = document.getElementsByTagName("div");
		// console.log(arrayOfDocFonts);
		for (var i = 0; i < arrayOfDocFonts.length; i++) {
			if (arrayOfDocFonts[i].style.display == "inline" && arrayOfDocFonts[i].className != "back-to-top")
			{
				arrayOfDocFonts[i].style.setProperty('visibility', !selected ? 'hidden': 'visible');
			}
		}
		$('.custom-btn').prop('selected', !selected);
		// var selected = $('.custom-btn').prop('selected');
		// console.log("after" + selected);
		// console.log("custom-btn: clicked!");
		return false;
	});
	
});

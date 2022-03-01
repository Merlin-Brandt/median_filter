1;

#imnoise (I, "salt & pepper", density 0 to 1)


pkg load image

maxfilter = @(img, domain) ordfiltn (img, nnz (domain), domain);
minfilter = @(img, domain) ordfiltn (img, 1, domain);

function fimg = wmedianfilter (img, domain)
	if (not (all (mod (size (domain), 2))))
		error("domain may only have odd paramters");
	endif
	# dimensions of the sides of the center of the domain matrix (excluding the center)
	sidesw = floor (0.5 * size (domain));
	center = sidesw + 1;
	pimg = padarray (img, sidesw);

	fimg = img;

	for y = 1 : rows (img)
		for x = 1 : columns (img)
			list = zeros (1, sum (sum (domain)));
			i = 1; # for the list
			for nx = -sidesw(1):sidesw(1)
				for ny = -sidesw(2):sidesw(2)
					repetitions = domain(nx + center(1), ny + center(2));
					pixel = pimg(y + ny + sidesw(2), x + nx + sidesw(1));
					list(i:(i+repetitions-1)) = ones (1, repetitions) * pixel;
					i = i + repetitions;
				endfor
			endfor
			fimg(y, x) = median (list);
		endfor
	endfor
endfunction

function s = wmfblock (neigh, domain)
	s = median ((neigh .* domain)(:));
endfunction

#medianfilter = @(img, domain) ordfiltn (img, nnz (domain) / 2, domain);

function mat = square (w)
	mat = ones (w);
	mat = logical (mat);
endfunction

function mat = verticalline (w)
	if ((mod (w, 2) == 0))
		adjust = 2;
	else
		adjust = 1;
	endif

	zerow = floor ((w-1) / 2);

	mat = [(zeros (w, zerow)), (ones (w, adjust)), (zeros (w, zerow))];
	mat = logical (mat);
endfunction

function mat = horizontalline (w)
	mat = verticalline (w)';
endfunction

function mat = cross (w)
	mat = max (verticalline (w), horizontalline (w));
endfunction

function mat = circle (w)
	mat = [];
	for y = 1:w
		line = [];
		for x = 1:w
			if (((x-0.5) - w/2)^2 + ((y-0.5) - w/2)^2 <= (w/2-0.5)^2)
				line(end+1) = 1;
			else
				line(end+1) = 0;
			endif
		endfor
		mat = [mat; line];
	endfor
	mat = logical (mat);
endfunction

function fimg = repeat (n, f, img, domain)
	fimg = img;
	for i = 1:n
		fimg = f (fimg, domain);
	endfor
endfunction

function setsliderstep1 (slider)
	maxSliderValue = get(slider, 'Max');
	minSliderValue = get(slider, 'Min');
	theRange = maxSliderValue - minSliderValue;
	steps = [1/theRange, 10/theRange];
	set(slider, 'SliderStep', steps);
endfunction

function ui (I, filter)

	f = figure;

	style = "slider";

    rs = uicontrol (f, "style", style, "min", 0, "max", 7, "value", 0);
	set (rs, "position", [10, 10, 200, 30])

	windowsize = uicontrol (f, "style", style, "min", 3, "max", 10, "value", 3);
	set (windowsize, "position", [220, 10, 200, 30])

	domain = uicontrol (f, "style", "edit", "string", "ci");
	set (domain, "position", [10, 40, 200, 30])

	set (rs, "callback", {@update, I, rs, windowsize, domain, filter})
	set (windowsize, "callback", {@update, I, rs, windowsize, domain, filter})
	set (domain, "callback", {@update, I, rs, windowsize, domain, filter})

	setsliderstep1 (rs)
	setsliderstep1 (windowsize)



	update ([], [], I, rs, windowsize, domain, filter)
endfunction

function d = str2domain (str, w)
	if (str == "ci")
		d = circle (w);
	elseif (str == "sq")
		d = square (w);
	elseif (str == "cr")
		d = cross (w);
	else
		d = square (w);
	endif
endfunction

function update (src, data, I, rs, windowsize, domain, f)
	v = get (rs, "value");
	v = int32 (v)
	w = int32 (get (windowsize, "value"))
	s = get (domain, "string")
	imshow (repeat (v, f, I, str2domain (s, w)));
	disp done
endfunction

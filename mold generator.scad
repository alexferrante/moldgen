/*
Configuration of mold parameters according to your model 
*/
model_filename = "filename.stl"; 
model_rotate = [180,66,0];
model_translate = [0,8,9];
model_scale = 2;

rounded_corners = true;		
edge_radius = 8;			// Rounded corner radius 
mold_width = 41;			// X axis
mold_height = 55;			// Y axis
mold_depth = 20;			// Z axis
mold_spacing = 10;			// Spacing between mold halves

//Insert configuration
insert_size = 3;		
insert_fettle = 0.4;		// Size difference between inserts and holes
insert_margin = 7;	        // Positioning from outer edge of mold

//Pour hole configuration
pour_hole_r1 = 8;			// Outer hole radius
pour_hole_r2 = 5;			// Inner hole radius 
pour_hole_height = 14.5;		// Height of the pour hole
pour_hole_translate = [0, 30, 18.5];
pour_hole_rotate = [90, 0, 0];

translateHalves();

/*
Put mold halves next to each other
*/
module translateHalves() {
	// Scoot the left half over a bit
	translate([mold_width/2 + mold_spacing/2, 0, mold_depth/2])
		bottom_half();
		
	// Rotate the top half, then scoot it over a bit
	translate([-mold_width/2 - mold_spacing/2, 0, mold_depth*3/2])
		rotate([0, 180, 0])
			top_half();	
}

/*
Generate bottom half of mold 
*/
module bottom_half() {
	difference() {

		difference() {
			if (rounded_corners) 
				generateMold([mold_width, mold_height, mold_depth], edge_radius, true);
			else
				cube(size = [mold_width, mold_height, mold_depth], center = true);
            
			scale(model_scale)
				translate(model_translate)
					rotate(model_rotate)
						import(model_filename);
		}

		// insert hole 1
		translate([-mold_width/2 + insert_margin, -mold_height/2 + insert_margin, mold_depth/2])
			sphere(insert_size + insert_fettle, $fn = 30);

		// insert hole 2
		translate([mold_width/2 - insert_margin, mold_height/2 - insert_margin, mold_depth/2])
			sphere(insert_size + insert_fettle, $fn = 30);
	}

	// insert 1
	translate(v = [-mold_width/2 + insert_margin, mold_height/2 - insert_margin, mold_depth/2])
		sphere(r = insert_size, $fn = 30);

	// insert 2
	translate(v = [mold_width/2 - insert_margin, -mold_height/2 + insert_margin, mold_depth/2])
		sphere(r = insert_size, $fn = 30);
}

/*
Generate top half of mold
*/
module top_half() {
	difference() {

		difference() {
			translate([0, 0, mold_depth])
				if(rounded_corners) 
					generateMold([mold_width, mold_height, mold_depth], edge_radius, true);
				else
					cube(size = [mold_width, mold_height, mold_depth], center = true);

				scale(model_scale)
					translate(v = model_translate)
						rotate(model_rotate)
								import(model_filename);
		}

		// insert hole 1
		translate(v = [mold_width/2 - insert_margin, -mold_height/2 + insert_margin, mold_depth/2])
			sphere(insert_size + insert_fettle, $fn = 30);

		// insert hole 2
		translate(v = [-mold_width/2 + insert_margin, mold_height/2 - insert_margin, mold_depth/2])
			sphere(insert_size + insert_fettle, $fn = 30);

		// pour hole 
		translate(pour_hole_translate)
			rotate(pour_hole_rotate)
				cylinder(pour_hole_height, pour_hole_r1, pour_hole_r2);
	}

	// insert 1
	translate(v = [mold_width/2 - insert_margin, mold_height/2 - insert_margin, mold_depth/2])
		sphere(insert_size, $fn = 30);

	// insert 2
	translate(v = [-mold_width/2 + insert_margin, -mold_height/2 + insert_margin, mold_depth/2])
		sphere(insert_size, $fn = 30);

}

/*
Creates physical mold based on configuration
*/
module generateMold(size, radius, sidesonly)
{
	rot = [ [0,0,0], [90,0,90], [90,90,0] ];
	if (sidesonly) {
		cube(size - [2*radius,0,0], true);
		cube(size - [0,2*radius,0], true);
		for (x = [radius-size[0]/2, -radius+size[0]/2],
				 y = [radius-size[1]/2, -radius+size[1]/2]) {
			translate([x,y,0]) cylinder(r=radius, h=size[2], center=true);
		}
	}
	else {
		cube([size[0], size[1]-radius*2, size[2]-radius*2], center=true);
		cube([size[0]-radius*2, size[1], size[2]-radius*2], center=true);
		cube([size[0]-radius*2, size[1]-radius*2, size[2]], center=true);

		for (axis = [0:2]) {
			for (x = [radius-size[axis]/2, -radius+size[axis]/2],
					y = [radius-size[(axis+1)%3]/2, -radius+size[(axis+1)%3]/2]) {
				rotate(rot[axis]) 
					translate([x,y,0]) 
					cylinder(h=size[(axis+2)%3]-2*radius, r=radius, center=true);
			}
		}
		for (x = [radius-size[0]/2, -radius+size[0]/2],
				y = [radius-size[1]/2, -radius+size[1]/2],
				z = [radius-size[2]/2, -radius+size[2]/2]) {
			translate([x,y,z]) sphere(radius);
		}
	}
}

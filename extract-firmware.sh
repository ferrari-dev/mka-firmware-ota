#!/usr/bin/env bash

mkdir -p temp
rm -rf temp/*

images=$( ls images/*.tgz | grep -vE ".*\.firmware\.tgz$" )
for img in ${images[@]}; do
	img_base="$( basename $img )"
	img_name="${img_base%.*}"
	img_nomd5="${img_base%global_*}"global

	img_out="${img_nomd5}_*.firmware.tgz"

	if ls images/${img_out} 1> /dev/null 2>&1; then
		echo "skipping ${img_nomd5}; already done."
		continue;
	fi

	cd temp
	pv ../$img | tar -xzf -

	# go into extracted folder
	cd "${img_nomd5}"

	files=( cache.img recovery.img system.img userdata.img )
	for file in ${files[@]}; do
		rm -f images/$file
	done

	# back to temp
	cd ..

	tar -c "${img_nomd5}/" | gzip -n >"${img_nomd5}.tgz"
	md5suml=$( md5sum ${img_nomd5}.tgz )
	md5sums=${md5suml:0:10}

	mv "${img_nomd5}.tgz" ../images/"${img_nomd5}_${md5sums}.firmware.tgz"
	echo "${img_nomd5}_${md5sums}.firmware.tgz"

	# back to home base
	cd ..
done

rm -rf temp

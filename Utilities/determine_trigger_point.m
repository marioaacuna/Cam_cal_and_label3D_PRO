function x = determine_trigger_point(pt, n_points, intensity)

    derpt1 = diff(intensity(pt-n_points : pt));
    [~,max_idx] = max(derpt1);
    n_to_go_back = n_points - max_idx +1;
    x = pt-n_to_go_back;

end
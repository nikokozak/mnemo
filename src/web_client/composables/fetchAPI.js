export const fetchAPI = async (request, opts={}) => {
    opts.baseURL = 'http://localhost:4000';
    return await $fetch(request, opts);
}

// This is broken for some reason
export function useFetchAPI(request, opts={}) {
    return useFetch(request, { baseURL: 'http://localhost:4000', server: false, initialCache: false, ...opts});
}


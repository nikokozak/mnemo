// Wraps the $fetch api with a baseURL
export const useSimpleFetch = (request, opts={}) => {
    const config = useRuntimeConfig();    

    return $fetch(request, {
        baseURL: config.public.baseURL, 
        ...opts
    })
}

// Wraps the useFetch composable with defaults for client-side fetching.
export const useFetchAPI = (request, opts={}) => {
    const config = useRuntimeConfig();    
    
    return useFetch(request, { 
        baseURL: config.public.baseURL, 
        server: false, 
        initialCache: false,
        ...opts
    });
}


export function testMe() { console.log("works!"); }

export async function doPost(route, data) {
    const res = await fetch(route, {  
        method: 'POST',
        headers: {
            'Content-Type': 'application/json', 
        },
        body: JSON.stringify(data)
    })

    return res.json();
}

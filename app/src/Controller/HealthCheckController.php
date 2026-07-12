<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class HealthCheckController extends AbstractController
{
    #[Route('/health', name: 'app_health')]
    public function index(): Response
    {
        $results = [];
        $results[] = "Hello World!";
        
        return new Response(implode("\n", $results));
    }
}